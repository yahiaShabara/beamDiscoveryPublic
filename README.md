This repository contains the simulation codes for our paper,
### "Source Coding Based Millimeter-Wave Channel Estimation with Deep Learning Based Decoding"

If you find this code helpful or used it in your work, please cite this work.


## Description
This software simulates the process of channel estimation in sparse large-MIMO radio environments using a Binary Coding measurement Framework.
Classical channel estimation solutions would necessitate a large number of measurements for Large-MIMO systems.
This drives the estimation overhead to unacceptable and impratcical high levels.
Hence, our goal is to estimate/discover the channel using just a few measurements.
In sparse MIMO channels, only few channel paths exist.
This piece of information gives us the ability to accurately estimate the channel by discovering all of its paths.

Channel estimation is divided into two sub-problems.

- The first sub-problem is **Measuerment Design**, which we also call *Channel Encoding*.
We solve this problem with the help of binary linear source codes.
- The second subproblem is **Measuerment Interpretation**, which we also call *Measurement Decoding*.
We solve this problem using two different solutions:
  1- The *Search* Method:
  2- A machine learning based *DNN* method.

Our codes are mainly written in MATLAB, but we also use python for DNN decoding.




## Setup python environment

### 1- Install 'Anaconda'  
### 2- Open the 'Anaconda command prompt (window)'  
### 3- Create a new enivornemnt using:  
	`conda create --name <env-name> python=3.6`  
### 4- Install the following packages to the python environment created in step 3 above in the same order provided  
	i)  
	`conda install --name <env-name> tensorflow`  
	or if you have a GPU-enabled device  
	`conda install --name <env-name> tensorflow-gpu`  
	  
	ii)  
	`conda install --name <env-name> keras`  
  
	iii)  
	`conda install --name <env-name> mat4py`  
	or use   
	`pip install mat4py`  
	
	