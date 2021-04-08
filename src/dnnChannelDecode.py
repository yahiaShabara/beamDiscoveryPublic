from mat4py import loadmat, savemat
# import pickle
import numpy as np
import pdb
# import matplotlib.pyplot as plt
import tensorflow as tf
import os,sys
import time


def usage():
	print ( "\tReceived an invalid number of arguments when attempting to run {}".format( sys.argv[0] ) )
	print ( "\t\tusage is: {} <measurementsFile.mat> <dnnModelRX.h5> <dnnModelTX.h5>".format(sys.argv[0]) )
if __name__ == "__main__":
	if (len(sys.argv) != 4):
		usage()
		sys.exit()
	measurementsPath   = sys.argv[1]
	measurementsPath   = os.path.abspath(measurementsPath)
	
	sameModel = ( sys.argv[2] == sys.argv[3] ) # true == both DNN models for TX & RX bin mapping are identical
	if ( sameModel ):
		modelPath        = sys.argv[2]
		modelPath        = os.path.abspath(modelPath)
	else:
		modelRXPath        = sys.argv[2]
		modelRXPath        = os.path.abspath(modelRXPath)
		modelTXPath        = sys.argv[3]
		modelTXPath        = os.path.abspath(modelTXPath)
	

	MATLAB_data = loadmat(measurementsPath)
	# store into numpy arrays
	channelMeasurementsReal = np.array(MATLAB_data['AllY4pythonReal']) # real parts of measurements (concatenated side-by-side)
	channelMeasurementsImag = np.array(MATLAB_data['AllY4pythonImag']) # imaginary parts of measurements (concatenated side-by-side)
	# store into regular variables
	mr      = MATLAB_data['mr'] # number of RX measurements
	mt      = MATLAB_data['mt'] # number of TX measurements
	nr      = MATLAB_data['nr'] # number of RX antennas
	nt      = MATLAB_data['nt'] # number of TX antennas
	n_paths = MATLAB_data['n_paths'] # maximum number of channel paths
	nRuns   = MATLAB_data['nRuns']   # number of simulated channels
	SNR_dB  = MATLAB_data['SNR_dB']  # SNR value in dB

	print("\t\ttransposing matrices ... ")
	sys.stdout.flush()
	channelMeasurementsReal = np.transpose( channelMeasurementsReal ) # arrange RX measurements (real part) to be rows instead of columns
	channelMeasurementsImag = np.transpose( channelMeasurementsImag ) # arrange RX measurements (imag part) to be rows instead of columns
	print("\bdone")
	sys.stdout.flush()
	

	# ---------------------------------------
	# ---------------------------------------
	# Normalize Channel Measurements
	# print("\t\tnormalizing RX measurements ...")
	# sys.stdout.flush()
	# normalizeFactorReal     = np.divide(np.abs(channelMeasurementsReal).max(axis = 1) , 30)
	# normalizeFactorReal[normalizeFactorReal == 0] = 1
	# normalizeFactorImag     = np.divide(np.abs(channelMeasurementsImag).max(axis = 1) , 30)
	# normalizeFactorImag[normalizeFactorImag == 0] = 1
	# channelMeasurementsReal = np.divide(channelMeasurementsReal, normalizeFactorReal[:, None])
	# channelMeasurementsImag = np.divide(channelMeasurementsImag, normalizeFactorImag[:, None])
	# print("\bdone")
	# sys.stdout.flush()
	# ---------------------------------------
	# ---------------------------------------
	
	# load DNN models
	if ( sameModel ):
		model = tf.keras.models.load_model(modelPath)
	else:
		modelRX = tf.keras.models.load_model(modelRXPath)
		modelTX = tf.keras.models.load_model(modelTXPath)

	startTime = time.time() # records the start time of decoding
	

	# decode RX measurements
	print("\t\tpredicting RX bins ...")
	sys.stdout.flush()
	if ( sameModel ):
		estimatedRXChannelsReal = model.predict( channelMeasurementsReal )
		estimatedRXChannelsImag = model.predict( channelMeasurementsImag )
	else:
		estimatedRXChannelsReal = modelRX.predict( channelMeasurementsReal )
		estimatedRXChannelsImag = modelRX.predict( channelMeasurementsImag )
	print("\bdone")
	sys.stdout.flush()
	
	# ---------------------------------------
	# ---------------------------------------
	# DeNormalize RX Bins
	# print("\t\tdenormalizing RX bins ...")
	# sys.stdout.flush()
	# estimatedRXChannelsReal = np.multiply(estimatedRXChannelsReal, normalizeFactorReal[:, None])
	# estimatedRXChannelsImag = np.multiply(estimatedRXChannelsImag, normalizeFactorImag[:, None])
	# del normalizeFactorReal, normalizeFactorImag
	# print("\bdone")
	# sys.stdout.flush()
	# ---------------------------------------
	# ---------------------------------------


	# Perfect sparsity of RX measurements
	print("\t\tperfecting sparsity of RX bins ...")
	sys.stdout.flush()
	allRxIndeces = np.array( range(nr) )
	estimatedRXChannelsAbs = np.abs(estimatedRXChannelsReal + 1j*estimatedRXChannelsImag) # magnitude of the estimated RX bins
	maxk_AbsRxBins  = np.argpartition(estimatedRXChannelsAbs, -1*n_paths)[:,-1*n_paths:] # find the indeces of the max n_paths components of estimatedRXChannelsAbs
	for i in range(estimatedRXChannelsAbs.shape[0]):
		diff = np.setdiff1d(allRxIndeces, maxk_AbsRxBins[i,:], assume_unique = True) # find indeces of of the smallest (nr - n_paths) components
		estimatedRXChannelsReal[i,diff] = 0 # zero out all small (nr-n_paths) values of Real RX bins
		estimatedRXChannelsImag[i,diff] = 0 # zero out all small (nr-n_paths) values of Imag RX bins
	del estimatedRXChannelsAbs, allRxIndeces, diff, i # delete unused variables
	print("\bdone")
	sys.stdout.flush()
	
	# arrange all decoded rx vectors for further processing
	print("\t\treshaping RX bins for further processing ...")
	sys.stdout.flush()
	estimatedRXChannelsReal = estimatedRXChannelsReal.reshape(nRuns,mt,nr).transpose((0,2,1)).reshape((nRuns*nr,mt))
	estimatedRXChannelsImag = estimatedRXChannelsImag.reshape(nRuns,mt,nr).transpose((0,2,1)).reshape((nRuns*nr,mt))
	print("\bdone")
	sys.stdout.flush()
	
	# ---------------------------------------
	# ---------------------------------------
	# Normalize TX Channel Measurements
	# print("\t\tnormalizing TX measurements ...")
	# sys.stdout.flush()
	# normalizeFactorReal     = np.divide(np.abs(estimatedRXChannelsReal).max(axis = 1) , 30)
	# normalizeFactorReal[normalizeFactorReal == 0] = 1
	# normalizeFactorImag     = np.divide(np.abs(estimatedRXChannelsImag).max(axis = 1) , 30)
	# normalizeFactorImag[normalizeFactorImag == 0] = 1
	# estimatedRXChannelsReal = np.divide(estimatedRXChannelsReal, normalizeFactorReal[:, None])
	# estimatedRXChannelsImag = np.divide(estimatedRXChannelsImag, normalizeFactorImag[:, None])
	# print("\bdone")
	# sys.stdout.flush()
	# ---------------------------------------
	# ---------------------------------------

	# decode TX measurements
	print("\t\tpredicting TX bins ...")
	sys.stdout.flush()
	if ( sameModel ):
		estimatedTXChannelsReal = model.predict( estimatedRXChannelsReal )
		estimatedTXChannelsImag = model.predict( estimatedRXChannelsImag )
	else:
		estimatedTXChannelsReal = modelTX.predict( estimatedRXChannelsReal )
		estimatedTXChannelsImag = modelTX.predict( estimatedRXChannelsImag )
	print("\bdone")
	sys.stdout.flush()
	
	# ---------------------------------------
	# ---------------------------------------
	# DeNormalize TX Bins
	# print("\t\tdenormalizing TX bins ...")
	# sys.stdout.flush()
	# estimatedTXChannelsReal = np.multiply(estimatedTXChannelsReal, normalizeFactorReal[:, None])
	# estimatedTXChannelsImag = np.multiply(estimatedTXChannelsImag, normalizeFactorImag[:, None])
	# del normalizeFactorReal, normalizeFactorImag
	# print("\bdone")
	# sys.stdout.flush()
	# ---------------------------------------
	# ---------------------------------------
	
	# Perfect sparsity of TX measurements
	print("\t\tperfecting sparsity of TX bins ...")
	allTxIndeces = np.array( range(nt) )
	estimatedTXChannelsAbs = np.abs(estimatedTXChannelsReal + 1j*estimatedTXChannelsImag) # magnitude of the estimated TX bins
	maxk_AbsTxBins  = np.argpartition(estimatedTXChannelsAbs, -1*n_paths)[:,-1*n_paths:] # find the indeces of the max n_paths components of estimatedTXChannelsAbs
	for i in range(estimatedTXChannelsAbs.shape[0]):
		diff = np.setdiff1d(allTxIndeces, maxk_AbsTxBins[i,:], assume_unique = True) # find indeces of of the smallest (nr - n_paths) components
		estimatedTXChannelsReal[i,diff] = 0 # zero out all small (nr-n_paths) values of Real TX bins
		estimatedTXChannelsImag[i,diff] = 0 # zero out all small (nr-n_paths) values of Imag TX bins
	del estimatedTXChannelsAbs, allTxIndeces, diff, i
	print("\bdone")
	sys.stdout.flush()
	
	# reshape decoded measurements for MATLAB processing (in the form [Q^a_1, Q^a_2, Q^a_3, ...])
	print("\t\treshaping decoded measurements ...")
	sys.stdout.flush()
	estimatedTXChannelsReal = estimatedTXChannelsReal.reshape((nRuns,nr,nt)).transpose((1,0,2)).reshape((nr,nt*nRuns))
	estimatedTXChannelsImag = estimatedTXChannelsImag.reshape((nRuns,nr,nt)).transpose((1,0,2)).reshape((nr,nt*nRuns))
	print("\bdone")
	sys.stdout.flush()
	
	# print execution time of the core decoding function (not counting load/save file execution times)
	endTime = time.time() # records the end time of decoding
	print ( "\t\tExecution Time = {} seconds".format(endTime - startTime) )
	
	dic =	{'AllQaFromPythonReal': estimatedTXChannelsReal.tolist(), 'AllQaFromPythonImag': estimatedTXChannelsImag.tolist()}

	decodeMeasurements_fname = 'decodedMeasurements_{}x{}_{}P_{}dB_SNR.mat'.format( nr, nt, n_paths, SNR_dB )
	decodeMeasurementsDir  = os.path.dirname(measurementsPath) # this is the 'temp/' directory absolute path
	decodeMeasurementsPath = ( os.path.join(decodeMeasurementsDir, decodeMeasurements_fname) )
	print("\t\tsaving decoded measurements file ...")
	sys.stdout.flush()
	savemat ( decodeMeasurementsPath , dic )	
	print("\bdone")
	sys.stdout.flush()
