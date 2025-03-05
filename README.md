# MATLAB Source Code for Causal Sets

This repository contains the source code for causal sets (causets) that I developed as part of my PhD project at the Department of Mathematics, University of York, from 2017 to 2021. The project was funded by the Engineering and Physical Sciences Research Council (EPSRC). The functions and scripts in the main directory of this repository complement the files of the simulations undertaken on the Viking Cluster, which is a high performance compute facility provided by the University of York. You can find the functions that have been used in the simulations in the repositories:
* ['diamondsprinkling', part 1/2](https://github.com/c-minz/diamondsprinkling)
* ['diamondresults', part 2/2](https://github.com/c-minz/diamondresults)

After the first simulations, I started to develop further methods and decided to use class files for this. Most of the functionality is also available through the MATLAB classes @Causet, @EmbeddedCauset, @SprinkledCauset.

Development environments: MATLAB R2019a, MATLAB R2020a

## How to Use the Source Code

Most of the functionality for causal sets developed in this project is available through the MATLAB class files @Causet, @EmbeddedCauset, @SprinkledCauset (each with a sub-directory). In order to create a causal set from a causal matrix, a link matrix or similar, use the command 

    Causet(...)

For creating and plotting a causet, create an object of an embedded causet with

    EmbeddedCauset(...)

A causet can also be generated by a sprinkling process, for which you may use

    SprinkledCauset(...)

The classes and functions are documented, to display their help type help followed by the function name in the MATLAB console. Be aware that the implementation of the embedding algorithm to obtain a EmbeddedCauset object from a Causet object has not been completed. However, an EmbeddedCauset object can also be generated by defining the point coordinates explicitly or by using the sprinkling process. Aside the class directories, the main directory of the repository contains further functions, some of which are already included in the class structure.

New code is developed mostly in the programming language Python such that the code can be used without a MATLAB licens. For the Python source code, see [Python-causets](https://github.com/c-minz/Python-causets).

## License Information

The source code is published under the BSD 3-Clause License, see [license file](LICENSE.md).

Copyright (c) 2020-2025, Christoph Minz
