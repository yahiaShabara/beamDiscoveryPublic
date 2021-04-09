This repository contains the simulation codes for our [paper](https://arxiv.org/pdf/1905.00124.pdf):   
**Source Coding Based Millimeter-Wave Channel Estimation with Deep Learning Based Decoding**

*If you find this code helpful or used it in your work, please cite this work:*


> @article{shabara2019source,  
> title={Source Coding Based Millimeter-Wave Channel Estimation with Deep Learning Based Decoding},  
> author={Shabara, Yahia and Ekici, Eylem and Emre Koksal, C},  
> journal={arXiv e-prints},  
> pages={arXiv--1905},  
> year={2019}}



## Description
This software simulates the process of channel estimation in sparse large-MIMO radio environments using a Binary Coding measurement Framework. 

Classical channel estimation solutions would necessitate a large number of measurements for Large-MIMO systems. This drives the estimation overhead to unacceptable and impractical high levels.
Hence, our goal is to estimate/discover the channel using just a few measurements.
Sparse MIMO channels only contain few channel paths. This piece of information gives us the ability to accurately estimate the channel, by discovering all of its paths, using fewer measurements compared to the channel dimensions.

Channel estimation is divided into two sub-problems.

- The first sub-problem is **Measuerment Design**, which we also call ***Channel Encoding***.
We solve this problem with the help of binary linear source codes.
- The second sub-problem is **Measuerment Interpretation**, which we also call ***Measurement Decoding***. Due to the complexity of joint measurement processing, we devise a technique which allows us to break down the decoding problem into several smaller sub-problems that can be run in parallel. Each of the sub-problems can be solved using a wide range of techniques that can be selected from the realm of sparse recovery solutions. We, however, propose two different solutions:  
  1- The *Search* decoding method.
  2- A machine learning based *DNN* (Deep Neural Network) decoding method.  
The search deocder attempts to optimally solve the sub-problems. However, compared to DNN decoding, the search decoder is significantly more computationally complex. Precisely, its complexity is $O({n \choose k})$, where $n$ is the number of anetnnas (at TX or RX) and $k$ is the number of paths.  Hence, it only makes sense to use the search decoding when the channel dimensions is relatively small, or when the number of paths is very small. The DNN decoding, however, is computationally tractable, yet not optimal. Most importantly, the DNN decoder's performance is very close to the optimal search decoder, and its complexity, which depends on the size of the used model, justifies this small sacrifice in perfromance.

Our codes are mainly written in `MATLAB`, but we also use `python` for DNN decoding. If you choose to use the search decoder, there is no need to worry about the python codes or the python environment. If you choose to use the DNN decoder, you will need to make sure the python environment is correctly set up, with all the required packages/libraries installed. You also need to make sure that MATLAB knows how to use (or activate) that python environment.


## Python environment setup

To be able to use the DNN based decoder, you will need to set up a python environment with all the necessary packages installed. We use tensorflow and keras to train and use the DNN models. The python functions will be automatically called from MATLAB using system calls, i.e., `system()`.

My favorite way of setting up the python environment is by using Miniconda, or Anaconda. You can either use my method, or you can use your any other method your prefer. To use Anaconda, follow these steps:
1- Install 'Anaconda' and open the 'Anaconda command prompt'
2- Create a new enivornemnt using:
	`conda create --name <env-name> python=3.8`  
3- Install the following packages to the python environment created in step 2 above:
 1. `conda install --name <env-name> tensorflow` or if you have a GPU-enabled machine, then use `conda install --name <env-name> tensorflow-gpu`
 2. `conda install --name <env-name> keras`  
 3. `conda install --name <env-name> matplotlib`  
 4. `conda install --name <env-name> mat4py`  	or use   `pip install mat4py`  

For MATLAB to be able to run python code, you need to correctly set the python you need to set the python executable variable, i.e., `pythonX`, in `src/main.m`.
The easiest way for this to work is to setup a python environment and make it your system's default by correctly setting up the environment variables. Then, set `pythonX = 'python'`.
If your prefer to use a virtual environment, this gets a little bit tricky. In earlier Miniconda versions, I was able to set `pythonX` to the python.exe executable file, which can be found under `<anaconda-files>/envs/<env-name>/python.exe`, and that was enough.
Recently, I found issues with this method, which requires an explicit environment activation call. To solve this, I now also provide this activation call inside the MATLAB system call which runs any python script. However, I was lazy and hard-coded my virtual environment name, which is `"dnn"`. Until I have a proper fix for this problem, you can either name your virtual environemnt "dnn", or change the code to accept your new environment name. 
***I will try to fix this ASAP. If you still have problems running python codes related to this issue, or run into other problems, please let me know.***


	
## DNN models
### Trained models
The DNN models we trained and used in our paper are made available online so researchers can easily reproduce our results.

 1. For single-path channels ($k\leq1$ path) with $n_r = 15$ receive
    antennas and $n_t = 31$ transmit antennas, the models can be found [here](https://drive.google.com/file/d/1TjM0aIYAm4YdUivvyPI83Uj729T0Xaft/view?usp=sharing).
 2.  For multi-path channels ($k\leq3$ paths) with $n_r = 23$ receive
    antennas and $n_t = 23$ transmit antennas, the models can be found [here](https://drive.google.com/file/d/1cOjbHmGLdKijKCp9RCD5p15jERSf2AKv/view?usp=sharing).
 3.  For multi-path channels ($k\leq3$ paths) with $n_r = 15$ receive
    antennas and $n_t = 32$ transmit antennas, the models can be found [here](https://drive.google.com/file/d/1NDWXW0GsWdf1ZxTB5kcKVA0q7gaxKIdk/view?usp=sharing).

### Training your own models

To train your own DNN models, you need to run the MATLAB function `trainDNN()` which is defined in `trainDNN.m` and can be found under `/src/trainingDNNs/`. This function takes as arguments the number of transmit and receive antennas, the number of channel paths, the SNR (in dB), the quantization resolution (in bits), the measurement Error Correction flag (set this to `0` if you do not know what it does) and finally, a path to the python executable `pythonX`.
This function will create training and testing data sets, if they don't exist and then will start the model training. The trained model will be saved under `/dnnModels/` in appropriate sub-folders for the channel parameters and the ADC quantization resolution.

## Running Simulations

The main file you need to run is `main.m`, which is a MATLAB script that sets up the simulation parameters and calls the relevant simulation functions.

In `main.m`, you need to set:

1. Channel Parameters:
	1. Number of TX antennas `n_t`
	2. Number of RX antennas `n_r`
	3. Number of paths `n_paths`
2. Simulation Flags:
	1. `add_noise`
		1. set to `1`  to add AWGN noise
		2. set to `0`  otherwise
	2. `perfect_ADC`
		1. set to `1`  to assume no quantization errors (perfect ADC).
		2. set to `0`  to allow quantization noise. ADC quantization resolution will be set separately below.
	3. `Error_corr` is a flag that indicates whether you want to add measurements to further increase reliability of the measurement process. This process is described in [this paper](https://ieeexplore.ieee.org/abstract/document/8750903). A brief explanation is provided below
		1. set to `1` to allow the error correction capability.
		2. set to `0` to diable the error correction capability.
	4. `pathOnGrid` 
		1.  Always set this to `1`.  This is a flag that determines whether channel paths lies on the angular grid defined by the DFT matrices $\boldsymbol{U_t}$ and $\boldsymbol{U_r}$, or could lie anywhere.
		2. To be able to safely set this to `0`, i.e., allow paths to exist anywhere in the angular space, you would need to carefully design the beamforming vectors $\boldsymbol{w_i}$ and $\boldsymbol{f_j}$ so that beam-overlap is eliminated, and side-lobes are suppressed. This is one possible extension of this work.
3. Simulation Parameters:
	1. `nRuns` The number of simulation runs (channel instances to be estimated) 
	2. `quantizationBits` The ADC resolution in bits. We use mid-tread ADCs with a number of quantization levels $=2^b+1$, where $b \triangleq$ quantizationBits.
	3. `SNR_dB` An array of SNR values in dB at which the simulation will be repeated. A separate file containing the performance metrics values is created and stored for each SNR value.
	4. `decodingMethod` 
		1. Set `decodingMethod = "search"`  to use the search decoder
		2. Set `decodingMethod = "dnn"`  to use the DNN decoder
	5. `noiseDefense` Only relevent for DNN decoder.
		1. Set to `1` to use specially trained DNN models for each SNR and ADC resolution value.
		2. Set `0` to use one DNN model, trained without AWGN noise, for all SNR values.
	6. `minPathGain`
		This is the minimum value for a path gain for a path to be considered as a "strong"  channel path.
	7. `pythonX`
		This is the path to the python executable file (python.exe) of your python (virtual) environment.



## The Error Correction Capability
As explained in [our paper](https://arxiv.org/pdf/1905.00124.pdf) on Source Coding Coding Based Measurement Design, the measurements in a SIMO channel are designed to mimic the equation 
$\boldsymbol{y^s} = \boldsymbol{G} \boldsymbol{q^a}$,
where $\boldsymbol{y^s}$ is the measurement vector, $\boldsymbol{q^a}$ is the angular channel, and $\boldsymbol{G}$ is the Generator matrix of an appropriately selected source code.

To further increase the measurement reliability, a technique based on Linear Block Codes is described in [our earlier paper](https://ieeexplore.ieee.org/abstract/document/8750903) is propsed. Essentially, we can envisage $\boldsymbol{y^s}$ to be an information sequence that would be stored/transmitted in a noisy environment. In noisy environments, errors are bound to happen. To allow for some of these errors to be corrected, we add some redundant measurements to $\boldsymbol{y^s}$ using an encoding-like process of Linear Block Codes (LBC).

Suppose that an appropriate LBC for this problem has a generator matrix $\boldsymbol{G_c}$. Then, we encode $\boldsymbol{y^s}$ using $\boldsymbol{G_c}$ as follows:
$\boldsymbol{y^s_{\nu}} =  \boldsymbol{G_c} \boldsymbol{y^s} = \underbrace{\left(\boldsymbol{G_c}\boldsymbol{G}\right) }_{\boldsymbol{G_{\nu}}}\boldsymbol{q^a}$.
The matrix $\boldsymbol{G_{\nu}}$ is calculated as the product of $\boldsymbol{G_c}$ and $\boldsymbol{G}$ over the binary field (i.e., Galois Field, GF(2)). Thus, it remains a binary matrix, similar to $\boldsymbol{G}$. 

Finally, instead of designing the measurements $\boldsymbol{y^s}$ based on the matrix $\boldsymbol{G}$, our new measurement vector is $\boldsymbol{y^s_{\nu}}$ and is desgined based on the matrix $\boldsymbol{G_{\nu}}$.
