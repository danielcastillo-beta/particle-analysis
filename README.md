# Image-based gradation and aggregate characterization

MATLAB code and files. There are three steps before calculating the gradation, with three corresponding functions (``fun_A``, ``fun_B``, and ``fun_C``). You can go folder by folder, opening and running the functions as-is. The necessary files are provided.

- _Note 1:_ MATLAB requires the Image Processing Toolbox and the Mapping Toolbox.
- _Note 2:_ This code is associated to the paper _"Image-based gradation and aggregate characterization: Case of cement-stabilized quarry fines"_ by Daniel Castillo, Yinning Zhang, and Leena Korkiala-Tanttu (Road Materials and Pavement Design).


## **Step 1.** Original to binary image, ``fun_A``
Use this function for image preparation and thresholding.

> Open and run ``fun_A``. The binary image is saved, and a folder is created with associated information (composite of image processes, separate images per processes, and histograms). The name of the folder is the name of the sample plus the image processes applied.

### Parameters

- Specify the name of the sample image (``smpName``) from the ``[smp]`` folder (without file extension). This folder contains the images used in the manuscript — see Figure 2:
    - Low resolution (57 px/mm): Specimens _A_ and _B_.
    - High resolution (371 px/mm): Specimens _C_, _D_, _E_, and _F_ (details of Specimen _A_), and Specimen _H_ (detail of specimen _B_).
- Specify the extension of your files (``ext``).
- The threshold (``thres``) can be specified manually; otherwise, a value is determined automatically.
- Specify the series of image processes to be applied in the cell array ``imgIters``. Defaults are as in the manuscript.
- You can also change the name of the input folder (``dirSmp``).

_Note:_ ``man_A`` is a manager function. It can be used to run ``fun_A`` automatically, to test a range of thresholds and other parameters as needed.


## **Step 2.** Extract particle boundaries, ``fun_B``
Use this function to extract particle boundaries and reduce boundary complexity.

> Open and run ``fun_B``. A folder is created, containing a plot and the aggregate coordinates file (``AG_xy``). This text file lists the closed _x-y_ coordinates of the individual aggregates, preceded by an aggregate number. Aggregates are separated by ``NaN``.

### Parameters

- Specify the name of the sample image (``smpName``) from the ``[bin]`` folder. This folder contains the binary images resulting from Step 1.
- Specify a threshold for minimum polygon area, using the radius of an equivalent circle (``rmin``), or directly using the area (``minArea``).
- Specify the scale of the sample image (``pxScl``) in [px/mm]. An arbitrary default is also provided (1 px/mm).
- A tolerance is used for edge reduction. The tolerance is proportional to the number of vertices of the boundary. It is interpolated logarithmically between a lower and higher limit (``tol1``, ``tol2``) for polygons with a 'low' and 'high' number of vertices (``nVrts1``, ``nVrts2``).
- Decide if ignoring or considering holes (``ignoreHoles``).
- You can also change the name of the input folder (``dirSmp``) and specify the progress interval to be printed while processing (``progInt``).

_Note:_ Depending on the sample image, ``AG_xy`` may contain aggregates with holes, and/or aggregates with centroid out of the polygon.


## **Step 3.** Analysis of aggregate coordinates, ``fun_C``
Use this function for particle-by-particle characterization.

> Open and run ``fun_C``. A folder is created, containing a table of aggregate properties (``AG_table``), the aggregate coordinates sorted by area (``AG_xy``), a list of _x-y_ centroid coordinates (``AG_xyc``), as well as _x-y_ specimen coordinates (``sp_xy``). The table of properties contains number of vertices, area, maximum radius, sieve size, retaining sieve, and rotation for all aggregates (see line 150 of ``fun_C``).

### Parameters

- Specify the specimen name (``smpName``) from the ``[AG_xy]`` folder. This folder contains the _x-y_ coordinates of the aggregates resulting from Step 2.
- Select the visualization type (``visType``), 0-3.
- In the cell array ``dirNames``, specify a number or specimen ID corresponding to the specimen names. An arbitrary default is also provided (``'0'``).
- Specify the sieve series (``svs``). Any arbitrary sieve series may be used. The sieves used in the manuscript are provided.
- Specify closed coordinates for the specimen (``sx``, ``sy``).
- You can also change the name of the input folder (``dirCrd``).

_Note:_ Notice that you can easily combine ``AG_xy`` files from different specimens. Simply copy and paste them sequentially into one file (keeping the ``NaN`` separation), then re-run ``fun_C`` to construct a joint table for the specimens.


## **Gradation.** ``xy_grad`` in folder ``step_3``
Use this function to calculate gradations.

> Open and run ``xy_grad``. A folder is created with the calculated gradation (``grads``) and associated files: area retained per sieve (``aRet``), number of aggregates retained per sieve (``nAgsSvs``), average and standard deviation of the number of vertices of the aggregates retained per sieve (``nVrtsMu``, ``nVrtsSigma``).

### Parameters

- Specify the specimen ID. You can calculate gradations for a sequence of specimens using ``nStrt`` and ``nEnd``.
- Specify the sieve series (``svs``). Any arbitrary sieve series may be used. The sieves used in the manuscript are provided.
- You can also change the name of the output folder (``gradSumName``).

---

## Additional functions in ``step_3``

### ``remAgs`` - Remove selected aggregates from an aggregate coordinates file (``AG_xy``):

- Depending on the sample image, the result of Step 2 (``fun_B``) may contain aggregates with centroid out polygon (i.e. 'fused' aggregates). When running ``fun_C``, these aggregates are listed in the command line and saved to a file.
- Specify ``smpName``, ``dirName``, and the list of aggregates to be removed (``remAgs``), and run the function.
- Running ``remAgs`` creates a new ``AG_xy`` coordinate file for the specimen. Use it to replace the previous file in the ``[AG_xy]`` folder, then run ``fun_C.m`` again to update the table of properties and other files.

### ``xy_plot`` - Plot specimens and selected aggregates:

- Specify the specimen ID. You can plot a sequence of specimens using ``nStrt`` and ``nEnd``.
- You can also single out individual aggregates (``plotAgs``) to be highlighted and plotted separately, or leave this list empty.
- Activate/deactivate title and axes (``tax``).
- You can also change the name of the output plot directory (``dirPlot``).

### ``xy_shape`` - _(Optional)_ Calculate shape parameters of the aggregates:

- Specify sequence of specimen IDs (``nStrt``, ``nEnd``).
- Running this code adds two extra columns to the table of properties (``AG_table``): Angularity Index and Form index.
- This code is provided to calculate morphological indices (angularity and form indices) of the aggregates, as presented in the manuscript.
