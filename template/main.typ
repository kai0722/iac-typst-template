// This template is licensed under the MIT-0 License. You can freely use and modify this template without any restrictions.
// #import "@preview/stellar-iac:0.4.1": project
#import "../lib.typ": project

#show: project.with(
  paper-code: "IAC-25-B4.7.13",
  title: "Ultra-high Precision Control Method Using an Extended Source Image for 
  the Formation Flying Synthetic Aperture Telescope and Its Application for Telescope-pointing Controls",
  authors: (
    (
      name: "Kai Nakamura",
      affiliation: "The University of Tokyo",
      corresponding: true,
    ),
    (name: "Norihide Miyamura", affiliation: "Meisei University"),
    (name: "Ryo Suzumoto",  affiliation: "ArkEdge Space Inc."),
    (name: "Satoshi Ikari", affiliation: "The University of Tokyo"),
    (name: "Shinichi Nakasuka", affiliation: "The University of Tokyo"),
  ),
  organizations: (
    (
      name: "The University of Tokyo",
      display: "Department of Aeronautics and Astronautics, The University of Tokyo, 7-3-1 Hongo, Bunkyo-ku, Tokyo, Japan",
    ),
    (
      name: "Meisei University",
      display: "Department of General Science and Engineering, Meisei University, 2-1-1 Hodokubo, Hino-shi, Tokyo, Japan",
    ),
    (
      name: "ArkEdge Space Inc.",
      display: "ArkEdge Space Inc., 3A, DOME ARIAKE HEADQUARTER 1-3-33 Ariake, Koto-ku, Tokyo, Japan",
    )
  ),
  keywords: (
    "Small Satellite",
    "Formation Flying",
    "Remote Sensing",
    "Image-based Optics"
  ),
  header: [76#super[th] International Astronautical Congress (IAC), Sydney, Australia, 29 Sep-3 Oct 2025.\ Copyright #{sym.copyright}2025 by the International Astronautical Federation (IAF). All rights reserved.],
  abstract: [
    The Formation Flying Synthetic Aperture Telescope concept aims to achieve high spatial and temporal resolution imaging by coherently combining light from multiple microsatellites to form a large virtual aperture for applications such as disaster monitoring. A critical challenge for realizing such a system is the requirement to control the relative positions and attitudes of the optical components with sub-wavelength accuracy, a task complicated by the absence of practical, high-precision absolute ranging sensors for small satellites. This research proposes and validates an "extended source image optimization method" to address this challenge. This method extends previous work that used stellar point spread functions by enabling the use of images of ground objects, which are extended and potentially variable sources, for precise aperture configuration tuning. The key principle involves evaluating the degree of optical interference from the observed image's statistical properties, specifically its standard deviation and power spectral density, and using this information as feedback to actively control the relative positions and attitudes of the satellites' optical units. The proposed method's efficacy was verified through both numerical simulations and a ground-based experimental testbed. The principal results demonstrate that wavelength-level accuracy in relative position and attitude control can be successfully achieved and maintained by feeding back information from extended source images alone, thereby overcoming the reliance on high-precision absolute distance measurements. The major conclusion is that this approach provides a viable pathway for implementing formation flying synthetic aperture telescopes. Furthermore, the study discuss applying the method to a sequence of telescope-pointing controls required to change the observation target.
  ],
)

#heading(numbering: none)[Nomenclature]
//数式に登場する文字の説明
/ $D_q$: Sub-Aperture Diameter
/ $D_"syn"$: Synthetic Aperture Diameter
/ $f$: Focal Length
/ $cal(F)$: Fourier transform
/ $I$: Image
/ $J$: Evaluation function
/ $p$: Image Pixel Pitch
/ $cal(P)$: Pupil Function
/ $Q$: Number of Sub-Apertures
/ $s$: Point Spread Function
/ $S$: Wavelength Intensity Distribution
/ $"std()"$: Standard Deviation
/ $bold(u)$: Image Sensor Coordinate System
/ $W$: Wavefront Aberration
/ $bold(x)$: Aperture Coordinate System
/ $z_i$: Distance between Exit Pupil and Image
/ $bold(delta)_q$: Shift in Relative Position and Attitude of Mirror Satellite
/ $lambda$: Observation Wavelength
/ $lambda_"ref"$: Reference Observation Wavelength

#heading(numbering: none)[Acronyms/Abbreviations]
/ CMOS: Complementary Metal-Oxide-Semiconductor
/ ESI: Extended Source Image
/ FFSAT: Formation Flying Synthetic Aperture Telescope
/ GEO: Geostationary Orbit
/ GSD: Ground Sampling Distance
/ PSD: Power Spectrum Density
/ PSF: Point Spread Function

= Introduction <chap:Introduction>
== Background <sec:Background>
Disaster monitoring with Earth-observing satellites constitutes a valuable information source, as it enables the simultaneous assessment of extensive ground conditions; hence, both spatial resolution and temporal resolution (i.e., observation frequency) are of critical importance@Nakasuka2018U.
Observations from low Earth orbit can achieve high spatial resolution. However, it is difficult to observe the same site with high frequency, which in turn requires a large constellation of satellites. Placing a satellite in geostationary orbit for so-called “stationary remote sensing” enables high-frequency observations, but it is harder to attain high resolution compared with low Earth orbit observations. To meet both requirements, the authors have proposed a system called the FFSAT (@fig:ffsat-concept-image), which uses formation flying. As one application example, they are examining an Australian wildfire monitoring mission @Suzumoto2023D.

#figure(
  image("./img/satellite/FFSAT_en_rev_3_2_crop.png"),
  caption: [FFSAT concept image @Suzumoto2023D],
) <fig:ffsat-concept-image>

As shown in @tab:ffsat-object, the currently designed and evaluated FFSAT can achieve both high-resolution observations with a GSD of 30 m and high-frequency observations on the order of minutes. However, to realize FFSAT it is necessary to determine and control the relative positions and attitudes of the optical modules aboard satellites operating in space with a precision on the order of one-tenth of the observation wavelength (a few hundred nanometres in the assumed infrared region) @Rousset2001.

#figure(
  table(
    columns: 4,
    table.header(
      [],
      [Symbol],
      [Unit],
      [Value (Summer, Winter)]
    ),

    [GSD], [GSD], [m], [60, 30],
    [Orbit Height], [$h$], [km], [35786(GEO)],
    [Observation Wavelength], [$lambda_"ref"$], [$upright(mu)$m], [4(Infrared)],
    [Image Pixel Pitch], [$p$], [$upright(mu)$m], [18],
    [Focal Length], [$f$], [m], [21.4, 10.7],
    [Synthetic Aperture Diameter], [$D_"syn"$], [m], [5.82, 2.91],
    [Piston Control Accuracy], [$delta z$], [nm], [400],
    [Tilt Control Accuracy], [$delta phi, delta theta$], [$upright(mu)$rad], [0.84],
  ),
    caption: [FFSAT specifications @Suzumoto2023D],
) <tab:ffsat-object>

In this study, we propose a method to maintain high spatial resolution with precision on the order of the observation wavelength by controlling the relative position and attitude of the optical system via feedback control using captured images during ground-based observations of the FFSAT. Additionally, after validating the control-law algorithm through numerical simulations, we conduct control experiments with an experimental setup that incorporates sensor and actuator noise, which is difficult to consider in purely numerical analyses.

== Objective <sec:Objective>
In ground-based observations with FFSAT, the central challenge is how to achieve, during imaging, alignment of the optical system’s relative position and attitude with respect to the mirror satellite at a precision on the order of the observation wavelength. Adaptive‐optics techniques make it possible to estimate and correct wavefront aberrations to sub‐wavelength accuracy. However, this capability depends on controlling the optical system’s relative position and attitude toward the imaging satellite with wavelength‐scale precision.

Accordingly, this study focuses on a control approach that reduces wavefront aberrations of several tens of wavelengths—introduced during ground‐based observation—to within two or three wavelengths. Specifically, we propose a method that determines the optical system’s relative position and attitude with respect to the mirror satellite by optimizing the ground‐captured images, thereby achieving the required control precision. Through this approach, we aim to obtain ground images with truly high spatial resolution.


== Structure <sec:Structure>
In @chap:PriorResearch, we review prior studies and clarify the existing issues.
In @chap:Method, we propose an in‐operation optical–system control law that, using information extracted from the observed images, controls the relative position and attitude of the optical system with respect to the mirror satellite to within observation-wavelength precision.
In @chap:Simulation, we validate the proposed control law through simulator‐based experiments.
Finally, in @chap:Experiment, we verify the control law in an optical experimental setup that accounts for environmental disturbances which are difficult to reproduce in simulation.


= Prior Research and Positioning of This Study <chap:PriorResearch>

As a prior study, we describe formation and maintenance control laws for FFSAT based on the point spread function (PSF). A related work is the PSF optimization method proposed by Suzumoto et al. (@Suzumoto2023D). In that study, both the initial formation control and the maintenance control of the FFSAT constellation are achieved by optimizing the PSF obtained when imaging a star (a point source). Figure @fig:psf-sample shows the PSFs before and after control, calculated by the authors with reference to @Suzumoto2023D. This method is founded on a “result-consistency” concept, which holds that an optimal PSF implies an optimal relative position and attitude of the optical system with respect to the imaging satellite. As noted in @Suzumoto2023D, this approach is required because no miniaturized, wavelength-scale absolute distance sensor suitable for small satellites currently exists. Consequently, sensing of the optimal relative position and attitude must rely on the observed images. This prior research demonstrated that, for point-source observation, formation and maintenance control with wavelength-scale precision can be realized by optimizing the PSF.

#figure(
  image("./img/sim/psf_image.png"),
  caption: [PSF Optimization Method before and after control (left: before, right: after) @Suzumoto2023D],
) <fig:psf-sample>

Based on the above, we can summarize the problem as follows. Prior research has shown that formation and maintenance control with wavelength‐scale precision is achievable by using images of point sources; however, in ground-based observations the target is not a point source (a star) but an extended source (the Earth’s surface). Although the prior work demonstrated that an ideal optical system can be established in orbit by observing stars, the key question is whether, after redirecting the line of sight from a star to the Earth’s surface while preserving the optical system’s relative position and attitude at wavelength‐scale precision, one can tune that relative position and attitude with respect to the imaging satellite to the same precision by optimizing the captured images. As with the PSF optimization method, no absolute distance sensor with the required precision exists for ground-based observation, so a result-consistent control approach is essential.

= Method <chap:Method>
== Overview <sec:Overview>
In this paper, we propose a line–of–sight control method for a synthetic aperture telescope based on the Extended Source Image (ESI) optimization technique. The ESI optimization technique enables in-operation formation maintenance with observation-wavelength precision by optimizing the images of extended sources captured by the synthetic aperture telescope, in the absence of high-precision absolute distance sensors.

The coordinate system definition in the ESI optimization method is shown in @fig:optical-coordinate.
$bold(u) = (u,v)$ is the coordinate system of the image sensor, and $bold(x) = (x,y)$ is the coordinate system of the aperture.
#figure(
  image("./img/coordinate/optics_coordinate_2.png"),
  caption: [Coordinate system definition focused on the optical system @Suzumoto2023D],
) <fig:optical-coordinate>

The observation image calculation in the algorithm is performed by convolving the true observation image with the PSF obtained by calculating the optical system’s pupil. The PSF calculation is shown in @eq:psf-calculation and @eq:psf-calculation-P.
When the relative position and attitude of the mirror satellite ($q$) is shifted by $bold(delta)_q$, the image of a point source (a star, etc.) is simulated, and the image (pixel information) obtained from the imaging unit is calculated.
The wavefront aberration of the synthetic aperture system is calculated from $bold(delta)_q$, and the PSF $s$ of the point source image is given by:

#set math.equation(number-align: bottom)
$
s(bold(u)) &= integral_(Delta lambda) S(lambda) s_(lambda)(bold(u), lambda) dif lambda \
       & prop integral_(Delta lambda) S(lambda) 
       abs(cal(F){cal(P)_lambda (bold(x), lambda)}_(f_x = u/(lambda z_i), f_y = v/(lambda z_i)))^2 
       dif lambda \
$ <eq:psf-calculation>
$
cal(P)_lambda (bold(x), lambda) &= sum_q^Q P_q dot exp[i dot 2pi/lambda W_q (bold(x), bold(delta_q))]
$ <eq:psf-calculation-P>


In the following, we describe the definition of the features, the image feedback gradient method, the ideal convergence state, and the control algorithm.

== Features <sec:Feature>

- *Image Standard Deviation*
The standard deviation of the image is used as the evaluation function for optimizing the image. The larger the standard deviation, the greater the contrast of the image.
The higher the contrast of the image, the clearer the image, and the better the image.

- *Image Power Spectrum Density*
The power spectrum density of the image is used to evaluate the spatial resolution of the image. It is the square of the absolute value of the two-dimensional Fourier spectrum obtained by two-dimensional Fourier transform of the image. The power spectrum density distribution can be used to evaluate the spatial frequency components of the image.

- *Wavefront Aberration of the Optical System*
The wavefront aberration of the optical system is used to evaluate the performance of the optical system. The wavefront aberration is an index indicating the flatness of the wavefront on the image plane of the optical system, and here it refers to the wavefront aberration caused by the relative position and attitude of the mirror satellite from the ideal configuration. The wavefront aberration is most affected by the Z-axis position shift of the mirror satellite. The smaller the wavefront aberration, the higher the performance of the optical system.

== Extended Image Feedback Gradient Method <sec:Gradient>

In the PSF optimization method, the relative position and attitude of the mirror satellite that optimizes the evaluation function is searched by the “image feedback gradient method”.
This image feedback gradient method is a method that sequentially updates the relative position and attitude of the mirror satellite in the gradient direction by the hill climbing method, and in the ESI optimization method, it is a problem that it takes a long time to optimize it alone. Therefore, in this study, we extended the image feedback gradient method to search for the relative position and attitude of multiple mirror satellites by the momentum term gradient descent method, and proposed a method that optimizes faster than the conventional method. This is called the “extended image feedback gradient method”.

== Ideal Convergence State <sec:Convergence>
If the Earth’s surface is given as the “true observation image” in @fig:true-image, the ideal observation image in the final convergence state achieved by the ESI optimization method is shown in @fig:planar-zero-W.
At this time, the “maximum relative aberration” between the mirror satellites is 0. If the Z-axis positions of all mirror satellites are consistent with the observation wavelength level, the optical system is almost in an ideal state. Here, for the sake of clarity in the presence or absence of interference, the observation image is represented by a color map.
Also, the PSF of the synthetic aperture at this time is shown in @fig:psf-zero-W. This is the point source image captured in an ideal configuration.
The interference occurs due to the overlap of the projection images of the mirror satellites, and such a geometric pattern is generated.

#figure(
  image("./data/sim_normal_6/test18_gray_256_256.png", height: 125pt),//TODO: change image
  caption: [True observation image @Chiriin],
) <fig:true-image>


#grid(
    columns: 2,
    [#figure(
        image("./data/sim_normal_6/planar_zero_W.png"),//TODO: change image
        caption: [Observation image of the extended source in the ideal state],
    ) <fig:planar-zero-W>
    ],
    [#figure(
        image("./data/sim_normal_6/psf_zero_W.png"),//TODO: change image
        caption: [PSF of the synthetic aperture at the time of observation @fig:planar-zero-W],
    ) <fig:psf-zero-W>
    ],
)

== Control Algorithm <sec:Algorithm>
=== Initial State <ssec:Initial>
The wavefront aberration of the optical system in the initial state is shown in @fig:initial-W. It can be seen that the relative position and attitude of the mirror satellites deviate from the ideal position and attitude. Also, it can be seen that the maximum relative aberration is about 10 times the observation wavelength.

#figure(
  image("./data/sim_normal_6/initial_W.png", height: 150pt),//TODO: change image
  caption: [Initial wavefront aberration of the mirror satellites],
) <fig:initial-W>

The ground observation image and the PSF of the synthetic aperture at this time are shown in @fig:planar-initial and @fig:psf-initial, respectively.
Compared with @fig:planar-zero-W and @fig:psf-zero-W, the ground observation image is blurred and the PSF of the synthetic aperture is blurred in the initial state because the relative position and attitude of the mirror satellites deviate from the ideal position and attitude.

#grid(
    columns: 2,
    [#figure(
        image("./data/sim_normal_6/planar_initial.png"),//TODO: change image
        caption: [Initial observation image],
    ) <fig:planar-initial>
    ],
    [#figure(
        image("./data/sim_normal_6/psf_initial.png"),//TODO: change image
        caption: [PSF of the synthetic aperture at the time of observation @fig:planar-initial],
    ) <fig:psf-initial>
    ],
)

=== Overlap Phase <ssec:Overlap>
In this phase, the images reflected by the mirror satellites and projected onto the imaging satellite are superimposed.
The evaluation function is @eq:J-overlap, and the relative position and attitude of the mirror satellites are optimized by the extended image feedback gradient method.

$
J_"overlap" = "std"(I)
$ <eq:J-overlap>
By superimposing the images of the mirror satellites, the standard deviation (contrast) of the synthetic image obtained by synthesizing the projection images of the mirror satellites is maximized.
The ground observation image and the PSF of the synthetic aperture after the superposition phase are shown in @fig:planar-overlap and @fig:psf-overlap, respectively.

#grid(
    columns: 2,
    [#figure(
        image("./data/sim_normal_6/planar_overlap.png"),//TODO: change image
        caption: [Observation image after superposition],
    ) <fig:planar-overlap>
    ],
    [#figure(
        image("./data/sim_normal_6/psf_overlap.png"),//TODO: change image
        caption: [PSF of the synthetic aperture at the time of observation @fig:planar-overlap],
    ) <fig:psf-overlap>
    ],
)

=== Interference Position Search Phase <ssec:Interference>
In this phase, the Z-axis position of each mirror satellite is optimized to search for the position where the interference is maximized.
By maximizing the interference, the spatial resolution of the image is also maximized.
The evaluation function is @eq:J-interference, and the relative position and attitude of the mirror satellites are optimized by the extended image feedback gradient method.
$
J_"interference" = sum_(bold(u)) abs(bold(u)) "PSD"(bold(u))
$ <eq:J-interference>
Here, $abs(bold(u))$ is multiplied by $"PSD"(bold(u))$ to weight the high-frequency components; the higher the frequency, the farther from the center of the two-dimensional power spectrum density distribution.

The ground observation image and the PSF of the synthetic aperture after the interference position search phase are shown in @fig:planar-interfere and @fig:psf-interfere, respectively.

#grid(
    columns: 2,
    [#figure(
        image("./data/sim_normal_6/planar_interfere.png"),//TODO: change image
        caption: [Observation image after interference position search],
    ) <fig:planar-interfere>
    ],
    [#figure(
        image("./data/sim_normal_6/psf_interfere.png"),//TODO: change image
        caption: [PSF of the synthetic aperture at the time of observation @fig:planar-interfere],
    ) <fig:psf-interfere>
    ],
)

This is the final phase, so the final wavefront aberration of the mirror satellites is shown in @fig:final-W.

#figure(
  image("./data/sim_normal_6/final_W.png", height: 150pt),//TODO: change image
  caption: [Final wavefront aberration of the mirror satellites],
) <fig:final-W>

Compared with @fig:initial-W, the maximum relative aberration is suppressed to about several times the observation wavelength.

= Verification by Numerical Simulation <chap:Simulation>
We verify the validity of the algorithm by Monte Carlo simulation.
== Simulation Conditions <sec:Condition>
The simulation conditions are shown in @tab:simulation-condition.
FFSAT considers different specifications for summer and winter, but here we use the winter specifications for the simulation.
#figure(
  table(
    columns: 4,
    align: (left, center, center, center),
    stroke: none,
    table.hline(),
    table.header(
      [],
      [Symbol],
      [Unit],
      [Value]
    ),
    table.hline(stroke: 0.4pt),
    [Synthetic Aperture Diameter], [$D_"syn"$], [m], [2.91],
    [Sub-Aperture Diameter], [$D_q$], [m], [0.50],
    [Sub-Aperture Number], [$Q$], [ ], [6],
    [Sub-Aperture Configuration], [ ], [ ], [Annular],
    [Focal Length], [$f, z_i$], [m], [10.7],
    [Reference Observation Wavelength], [$lambda_"ref"$], [$upright(mu)$m], [0.75],
    [Effective Observation Wavelength Bandwidth], [$Delta lambda$], [$upright(mu)$m], [0.04],
    [Wavelength Intensity Distribution], [$S(lambda)$], table.cell(colspan: 2)[Gaussian Distribution],
    [Minimum Position Control Accuracy], [ ], [$upright(mu)$m], [0.4],
    [Minimum Attitude Control Accuracy], [ ], [$upright(mu)$rad], [0.2],
    table.hline()
  ),
    caption: [Simulation Conditions],
) <tab:simulation-condition>


== Simulation Results <sec:SimulationResult>
The maximum relative aberration $W$ before and after the application of the ESI optimization method by Monte Carlo simulation is shown in @fig:W-before-and-after-ESI.
The initial maximum relative aberration is about $W = 20〜30$, but after the application of the ESI optimization method, it is suppressed to about $W = 1〜3$.
On the other hand, there are cases where the maximum relative aberration after control is $W > 70$. This is an example of falling into a local optimum. By analyzing these examples, it was found that the initial maximum relative aberration was $W > 40$ in common. From this, it is considered that the current ESI optimization method may fall into a local optimum when the initial maximum relative aberration is $W > 40$. In order to expand the application range of the ESI optimization method, further improvement is needed to avoid local optimum.
#figure(
  image("./data/sim_normal_6/W_before_and_after.png"),//TODO: change image
  caption: [Maximum relative aberration before and after the application of the ESI optimization method],
) <fig:W-before-and-after-ESI>

= Verification by Optical Experiment <chap:Experiment>
We perform a control experiment considering realistic effects such as imaging noise in the optical experiment system.
== Experiment Conditions <sec:ExperimentCondition>
The overview of the optical experiment system is shown in @fig:testbed-overall and @fig:testbed-around-mirror.
#figure(
  image("./img/exp/IMG_9656_lr.jpg"),//TODO: change image
  caption: [Overall view of the optical experiment system],
) <fig:testbed-overall>

#figure(
  image("./img/exp/IMG_9673_lr.jpg"),//TODO: change image
  caption: [Mirror satellite part of the optical experiment system],
) <fig:testbed-around-mirror>

The specifications of the experiment system are shown in @tab:experimant-condition.
Due to the limitations of the experiment system construction, the number of mirrors and other specifications are different from FFSAT, but they are sufficient conditions for verifying the effectiveness of the ESI optimization method.
#figure(
  table(
    columns: 4,
    align: (left, center, center, center),
    stroke: none,
    table.hline(),
    table.header(
      [],
      [Symbol],
      [Unit],
      [Value]
    ),
    table.hline(stroke: 0.4pt),
    [Synthetic Aperture Diameter], [$D_"syn"$], [m], [0.19],
    [Sub-Aperture Diameter], [$D_q$], [cm], [2.54],
    [Sub-Aperture Number], [$Q$], [ ], [3],
    [Sub-Aperture Configuration], [ ], [ ], [Annular],
    [Focal Length], [$f, z_i$], [m], [2.0],
    [Image Sensor], [ ], [ ], [CMOS],
    [Image Sensor Pixel Pitch], [p], [$upright(mu)$m], [1.85],
    [Reference Observation Wavelength], [$lambda_"ref"$], [$upright(mu)$m], [0.670],
    [Effective Observation Wavelength Bandwidth], [$Delta lambda$], [$upright(mu)$m], [0.01],
    [Coherence Length], [$l_c$], [$upright(mu)$m], [45],
    [Shutter Speed], [$T_(s s)$], [ms], [5],
    table.hline()
  ),
    caption: [Experiment Conditions],
) <tab:experimant-condition>

In the optical experiment system, the test chart shown in @fig:testchart is used as the true observation image.
#figure(
  image("./data/exp/testchart.png", height: 150pt),//TODO: change image
  caption: [Test chart used in the optical experiment system @TestChart],
) <fig:testchart>

The captured image at this time is shown in @fig:testbed-image-sample.
#figure(
  image("./data/exp/0deg_gain=1_start_0.png"),//TODO: change image
  caption: [Example of captured image in the optical experiment system],
) <fig:testbed-image-sample>

== Experiment Results <sec:ExperimentResult>
The results of each phase after applying the ESI optimization method in the optical experiment system are shown in @fig:testbed-result-all.
In particular, it can be confirmed that the projected images are actually superimposed in the superposition phase.
This image is used as the control input, and the same image as in the numerical simulation is used.
#figure(
  image("./data/exp/result_all.png"),//TODO: change image
  caption: [Captured image at each step],
) <fig:testbed-result-all>

To confirm that the interference has increased after the interference position search phase, the brightness value distribution of the center of the captured image before and after the interference position search is shown in @fig:testbed-center-before-ESI and @fig:testbed-center-after-ESI.
This is the distribution of the part indicated by the red circle in the center of the image of the 4th image in @fig:testbed-result-all.
#figure(
  image("./data/exp/zoom_before.png"),//TODO: change image
  caption: [Brightness value distribution of the center of the captured image before control],
) <fig:testbed-center-before-ESI>

#figure(
  image("./data/exp/zoom_after.png"),//TODO: change image
  caption: [Brightness value distribution of the center of the captured image after control],
) <fig:testbed-center-after-ESI>

It can be confirmed that the interference has increased from @fig:testbed-center-after-ESI. Therefore, it can be said that the spatial resolution has improved.

= Application to Telescope-Pointing Control <chap:Application>
For a distributed optics system like FFSAT, the telescope's pointing direction can be changed by moving each optical element independently. To minimize fuel consumption, this study adopts a strategy of fixing the imaging satellite's position and changing the pointing direction by moving the mirrors on the mirror satellites using their actuators(@fig:telescope-pointing-case3), rather than controlling the formation's center of gravity(@fig:telescope-pointing-case1) or assuming large sensors in the imaging satellite(@fig:telescope-pointing-case2). The key challenge is to perform this maneuver while maintaining the precise formation required for high-resolution imaging. This involves two main considerations: a method for calculating the required displacement for each mirror, and control and correction methods to minimize formation geometry errors during and after the maneuver.

#figure(
  image("./img/telescope-pointing-case1.png"),
  caption: [Telescope-pointing control method case 1],
) <fig:telescope-pointing-case1>

#figure(
  image("./img/telescope-pointing-case2.png"),
  caption: [Telescope-pointing control method case 2],
) <fig:telescope-pointing-case2>

#figure(
  image("./img/telescope-pointing-case3.png"),
  caption: [Telescope-pointing control method case 3],
) <fig:telescope-pointing-case3>

First, a method is proposed to calculate the necessary displacement for each mirror to achieve the desired change in pointing direction. Assuming the goal is to minimize the range of motion for the actuators, a three-step procedure is used:

1. Calculate a new target paraboloid, which is the ideal paraboloid on which the mirrors are positioned, rotated around the imaging satellite by the desired angle.
2. For each mirror's current position on the original paraboloid, compute the position on the new, rotated paraboloid that represents the shortest distance.
3. Calculate the displacement vector between the original and new positions and move the mirrors accordingly.

Second, to correct for formation errors that occur during this re-pointing sequence, two control strategies incorporating the ESI optimization method are proposed for testing and verification in a simulator.

/ Strategy A: The pointing direction is changed in a single step using a feed-forward control based on the calculated displacements. After the maneuver is complete, the ESI optimization method is applied to correct the final formation shape and restore high image quality.
/ Strategy B: The pointing direction change is implemented in multiple, smaller stages. The ESI optimization method is applied at each intermediate stage to continuously maintain formation accuracy throughout the entire maneuver.

The objective of these approaches is to ensure that high-spatial-resolution observations can be maintained both before and after the telescope's pointing direction is changed, enabling flexible and continuous observation capabilities.

= Conclusion <chap:Conclusion>
This study proposed the ESI optimization method, which is a method for controlling the relative position and attitude of the optical system with respect to the imaging satellite with observation-wavelength precision by optimizing the image of the extended source.
We also proposed the extended image feedback gradient method to speed up the ESI optimization method.

By performing numerical simulations, we verified the control law proposed by the ESI optimization method.
As a result, under the assumption that no disturbance is added to the satellite, the relative position and attitude of the satellite can be controlled to a precision far exceeding the mm order, which is the precision that can be observed by an absolute distance sensor.

By performing an experiment with the optical experiment system, we were able to show that the ESI optimization method is effective even when using a captured image with a camera.

Furthermore, this study explored the application of the ESI optimization method to telescope-pointing control sequences. This demonstrated the potential to maintain the required formation accuracy during dynamic maneuvers, such as changing observation targets, paving the way for the flexible and practical operation of the FFSAT.

#bibliography("references.bib", title: "References", style: "american-institute-of-aeronautics-and-astronautics")
