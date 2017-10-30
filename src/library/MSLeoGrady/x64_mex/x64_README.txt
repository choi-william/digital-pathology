Chris Alvino
6/1/13

In response to several requests for a 64-bit version of the MEX code, we have added this extra .zip file.

The QPBO was based on Vladimir Kolmogorov's quadratic pseudo boolean optimization (QPBO) implementation.  For reference, you can find the QPBO code at VK's site:http://pub.ist.ac.at/~vnk/software.html   However, you shouldn't need it (see the next paragraph).
 
Included are several files that you'll need for the x64 build.  You can build in mex with the line (from Matlab):
 
mex qpbo_mex.cpp QPBOint.cpp QPBO_postprocessingint.cpp QPBO_maxflow.cpp QPBO_extra.cpp
 
Note that I recommend having your current working directory be the folder where all these code files exist.