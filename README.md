<center><h1>Temperature-Aware Linux</h1></center>
<hr>

<br><br><br>
<h3>Abstract</h3>
<hr>

An Operating System may be called as temperature-aware, if it has the property of monitoring hardware 
temperatures ( like processor thermal parameters ), with selected processes or services being unavailable
when a particular threshold is exceeded. We propose a temperature-aware variant of the Linux Operating System 
where we combine various thermal-aware techniques to create a uniform temperature distribution on multi-core 
systems and control the temperature.

<h3>Introduction</h3>
<hr>

With the advancement of technology in the 21st century, there has been an increase in the demand for high 
performance which has led to better and faster systems with multi-core chips. However, these modern systems 
consume more power and their superior performance leads to elevated system temperatures. Moreover, multi-core 
systems often lead to non uniform temperature distribution over the chip and form hotspots. Hence, temperature 
control is now a critical issue for circuits as well as OS design.

<h3>Motivation</h3>
<hr>

The main motivation behind the project is to address the important issue of controlling hardware temperatures 
in modern multi-core systems, to increase the lifetime of the processor and prevent elevated temperatures 
from damaging the hardware.

<h3>Project Objectives</h3>
<hr>

The main objectives of our project are listed below.

1. Take any existing Linux OS and make it temperature-aware.
2. Keep track of various thermal parameters by retrieving system temperature values.
3. Control various processes running on the system based on the temperature values.
4. Take necessary actions like DFS, migrating cores and suspending processes if the threshold temperature is exceeded. 


<h3>Important Aspects</h3>
<hr>

We have implemented various temperature-aware techniques in our application which runs continuously, 
monitors system temperatures and takes action using the following techniques as mentioned below.

1. Dynamic Frequency Scaling
2. Core Hopping
3. Heat Balancing
4. Deferred Execution

Dynamic Frequency Scaling is mainly used to scale down the frequency of the cores as and when the need rises. 

Core Hopping is used to migrate only CPU intensive processes from the hotter to the cooler cores. 

Heat Balancing is used to migrate already running processes from the hotter cores to the cooler cores, to 
improve the efficiency of our core-hopping algorithm by balancing the thermal load.

Deferred execution of processes are used when some processes cause the temperature to exceed some safety limit 
over the threshold temperature.


