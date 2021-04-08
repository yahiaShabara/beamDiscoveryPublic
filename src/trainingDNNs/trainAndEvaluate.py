import pickle
import numpy as np
import pdb
import matplotlib.pyplot as plt
import tensorflow as tf
import os, sys
from scipy.io import loadmat, savemat
import copy
from keras import regularizers


def usage():
	print ( "\tReceived an invalid number of arguments when attempting to run {}".format( sys.argv[0] ) )
	print ( "\t\tusage is: {} <training-data.mat> <testing-data.mat> <DNN-Model.h5>".format(sys.argv[0]) )


if __name__ == "__main__":
	if (len(sys.argv) != 4):
		usage()
		sys.exit()
	
	trainingAbsPath   = os.path.abspath(sys.argv[1])
	testingAbsPath    = os.path.abspath(sys.argv[2])
	dnnModelAbsPath   = os.path.abspath(sys.argv[3])
	
	trainingDataDic   = loadmat(trainingAbsPath)
	q                 = trainingDataDic['q'].T
	ys                = trainingDataDic['ys'].T
	

	# create a random order for reshuffling training/testing data
	order   = np.random.choice(q.shape[0], q.shape[0], replace=False)
	x_train = ys[order]
	y_train =  q[order]
	
	testDataDic   = loadmat(testingAbsPath)
	x_evaluate    = testDataDic['ys'].T
	y_evaluate    = testDataDic['q'].T	
	
	k = np.zeros(x_evaluate.shape[0], dtype=np.int8)
	
	# Training
	#---------
	
	# Build Model
	model = tf.keras.models.Sequential()
	model.add(tf.keras.layers.Flatten( input_shape = x_train.shape[1:]) )
	model.add(tf.keras.layers.Dense(100             , activation = tf.nn.relu  ))
	model.add(tf.keras.layers.Dense(70             , activation = tf.nn.relu  ))
	model.add(tf.keras.layers.Dense(50             , activation = tf.nn.relu  ))
	model.add(tf.keras.layers.Dense(y_train.shape[1] , activation = tf.keras.activations.linear   ))
	
	bestModelPath = dnnModelAbsPath
	callbacks = [
		tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=8, verbose=0, min_delta=0, mode='auto'),
		tf.keras.callbacks.ModelCheckpoint(bestModelPath, monitor='val_loss', save_best_only=True, verbose=0),]
			
	# Compile Model
	model.compile(optimizer = 'adam', loss = 'mean_squared_error')
	# Train Model
	history = model.fit(x_train, y_train, shuffle=True, epochs = 200, validation_split = 0.3, batch_size = 300, callbacks=callbacks, verbose=2)
		
	# Evaluation
	#-----------
	print('Evaluating Model')
	model = tf.keras.models.load_model(bestModelPath)
	loss = model.evaluate(x_evaluate, y_evaluate, verbose=0)
	
	B     = np.argpartition(np.absolute(y_evaluate), -3)[:,-3:]
	estimatedChannels = model.predict(x_evaluate)
	B_hat = np.argpartition(np.absolute(estimatedChannels), -3)[:,-3:]
	for j in range(y_evaluate.shape[0]):
		try:
			trueDiscoveredBeams = np.intersect1d(B[j], B_hat[j])
			k[j] = len(trueDiscoveredBeams)
		except:
			print('Error :: The value of j is: ',j)
			pdb.set_trace()
			
	print(model.summary())
	#print(history.history['loss'])
	#print(history.history['val_loss'])
	print(loss)
	print( [ sum(k >= 1) , sum( k>= 2) , sum(k >= 3) ] )
	

#	pdb.set_trace()
#	plt.plot(testLoss)
#	plt.title('Model loss with noisy observations')
#	plt.ylabel('Loss')
#	plt.xlabel('SNR')
#	plt.grid(True, which = 'major')
#	plt.show()

#	currentDirectory = os.path.dirname(os.path.abspath(__file__))
#	fname = os.path.join(currentDirectory,'matlab_data','performance','DNNperformancewithDefense.mat')
#	dic =	{'k': k.tolist(), 'loss': testLoss}
#	savemat ( fname , dic )
