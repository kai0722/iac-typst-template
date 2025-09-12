// This template is licensed under the MIT-0 License. You can freely use and modify this template without any restrictions.
// #import "@preview/stellar-iac:0.4.1": project
#import "../lib.typ": project

#show: project.with(
  paper-code: "IAC-25-B4.7.13",
  title: "Ultra‑High‑Precision Control Using Extended‑Source Images for a Formation‑Flying synthetic aperture Telescope and Application to Telescope Pointing",
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
      display: "ArkEdge Space Inc., 3A, Dome Ariake Headquarter 1-3-33 Ariake, Koto-ku, Tokyo, Japan",
    )
  ),
  keywords: (
    "Small Satellite",
    "Formation Flying",
    "Remote Sensing",
    "Image‑Based Optics"
  ),
  header: [76#super[th] International Astronautical Congress (IAC), Sydney, Australia, 29 Sep–3 Oct 2025.\ Copyright #{sym.copyright}2025 by the International Astronautical Federation (IAF). All rights reserved.],
  abstract: [
    The Formation Flying Synthetic Aperture Telescope concept targets high spatial and temporal resolution by coherently combining light from multiple microsatellites to form a large virtual aperture for applications such as disaster monitoring. A central challenge is controlling the relative positions and attitudes of the optical elements with sub‑wavelength accuracy, which is difficult because practical, high‑precision absolute ranging sensors for small satellites are not available. We propose and validate an **extended‑source image optimization** method that addresses this challenge by extending prior work based on stellar point‑spread functions to images of ground scenes—i.e., extended and potentially time‑varying sources. The key idea is to infer the degree of optical interference from statistical properties of the observed image, specifically the intensity standard deviation and the power spectral density, and to use these as feedback signals to actively control the relative positions and attitudes of the satellites’ optical units. The method is verified through numerical simulations and a ground‑based experimental testbed. The principal result is that wavelength‑level accuracy in relative position and attitude control can be achieved and maintained using only extended‑source images, thereby eliminating reliance on high‑precision absolute distance measurements. We further discuss applying the method to sequences of telescope‑pointing maneuvers required to change observation targets.
  ],
)

#heading(numbering: none)[Nomenclature]
// Symbols used in equations
/ $D_q$: Sub‑Aperture Diameter
/ $D_"syn"$: Synthetic Aperture Diameter
/ $f$: Focal Length
/ $cal(F)$: Fourier Transform
/ $I$: Image
/ $J$: Evaluation Function
/ $p$: Image Pixel Pitch
/ $cal(P)$: Pupil Function
/ $Q$: Number of Sub‑Apertures
/ $s$: Point‑Spread Function
/ $S$: Spectral Intensity Distribution
/ $"std()"$: Standard Deviation (of image intensities)
/ $bold(u)$: Image‑Sensor Coordinate System
/ $W$: Wavefront Aberration
/ $bold(x)$: Aperture Coordinate System
/ $z_i$: Distance from Exit Pupil to Image Plane
/ $bold(delta)_q$: Shift in Relative Position and Attitude of Mirror Satellite
/ $lambda$: Observation Wavelength
/ $lambda_"ref"$: Reference Observation Wavelength

#heading(numbering: none)[Acronyms/Abbreviations]
/ CMOS: Complementary Metal‑Oxide‑Semiconductor
/ ESI: Extended‑Source Image
/ FFSAT: Formation‑Flying Synthetic Aperture Telescope
/ GEO: Geostationary Orbit
/ GSD: Ground Sampling Distance
/ PSD: Power Spectral Density
/ PSF: Point‑Spread Function

= Introduction <chap:Introduction>
== Background <sec:Background>
Earth‑observation satellites provide valuable information for disaster monitoring by enabling simultaneous assessment of wide areas; therefore, both spatial resolution and temporal resolution (i.e., observation frequency) are critical @Nakasuka2018U.
Low‑Earth‑orbit observations can achieve high spatial resolution; however, revisiting the same site frequently is difficult without a large constellation. In contrast, placing a satellite in geostationary orbit for “stationary remote sensing” enables high‑frequency observations but makes high spatial resolution more challenging than in low Earth orbit. To meet both requirements, we have proposed the FFSAT system (@fig:ffsat-concept-image), which uses formation flying. As one application, we are studying an Australian wildfire monitoring mission.

#figure(
  image("./img/satellite/FFSAT_en_rev_3_2_crop.png"),
  caption: [FFSAT concept image @Suzumoto2023D],
) <fig:ffsat-concept-image>

As summarized in @tab:ffsat-object, the current FFSAT design achieves both high resolution (GSD of 30 m) and high observation frequency on the order of minutes. Realizing FFSAT, however, requires determining and controlling the relative positions and attitudes of the optical modules in space with precision on the order of one‑tenth of the observation wavelength (a few hundred nanometers in the assumed infrared region) @Rousset2001.

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
    caption: [FFSAT specifications],
) <tab:ffsat-object>

In this study, we propose a method to maintain high spatial resolution by controlling the relative positions and attitudes of the optical system with wavelength‑scale precision using feedback from captured images in ground‑based observations of FFSAT. After validating the control law via numerical simulations, we conduct experiments with a laboratory testbed that incorporates sensor and actuator noise, which are difficult to model in purely numerical analyses.

== Objective <sec:Objective>
In ground‑based observations with FFSAT, the central challenge during imaging is to align the optical system’s relative position and attitude with respect to the mirror satellites at wavelength‑scale precision. Adaptive‑optics techniques can estimate and correct wavefront aberrations to sub‑wavelength accuracy, but they presuppose wavelength‑scale control of the optical system’s relative position and attitude with respect to the imaging satellite.

Accordingly, we focus on a control approach that reduces wavefront aberrations of several tens of wavelengths—introduced during ground‑based observation—to within two or three wavelengths. Specifically, we determine the relative position and attitude with respect to the mirror satellites by optimizing ground‑captured images, thereby achieving the required control precision and enabling truly high spatial resolution.

== Structure of this paper <sec:Structure>
In @chap:PriorResearch, we review prior studies and clarify open issues.
In @chap:Method, we propose an in‑operation control law that uses features extracted from observed images to control the relative position and attitude of the optical system with respect to the mirror satellites to within observation‑wavelength precision.
In @chap:Simulation, we validate the proposed control law through simulation.
Finally, in @chap:Experiment, we verify the control law with an optical testbed that captures environmental disturbances difficult to reproduce in simulation.

= Prior Research and Positioning of This Study <chap:PriorResearch>
As prior work, we consider formation and maintenance control laws for FFSAT based on the PSF. A related study by Suzumoto et al. from our research group proposed a PSF‑optimization method in which initial formation and maintenance control are realized by optimizing the PSF obtained when imaging a star (a point source). Figure @fig:psf-sample shows PSFs before and after control, computed by the authors. This method is based on a “result‑consistency” concept: an optimal PSF implies an optimal relative position and attitude of the optical system with respect to the imaging satellite. As noted in @Suzumoto2023D, this approach is necessary because no miniaturized, wavelength‑scale absolute distance sensor suitable for small satellites currently exists; consequently, the optimal relative state must be inferred from observed images. That prior research demonstrated that, for point‑source observations, formation and maintenance control with wavelength‑scale precision can be achieved by optimizing the PSF.

#figure(
  image("./img/sim/psf_image.png"),
  caption: [PSF optimization before (left) and after (right) control],
) <fig:psf-sample>

The open problem is summarized as follows. Prior research shows that wavelength‑scale formation control is achievable using images of point sources; however, in ground‑based observations the target is an extended source (the Earth’s surface). Although one can establish an ideal optical configuration in orbit by observing stars, the key question is whether, after redirecting the line of sight from a star to the Earth while preserving the wavelength‑scale relative state, we can re‑tune the relative position and attitude to the same precision by optimizing the captured extended‑source images. As with PSF optimization, an absolute distance sensor with the required precision is not available, so a result‑consistent, image‑based control approach is essential.

= Method <chap:Method>
== Overview <sec:Overview>
We propose a line‑of‑sight control method for a synthetic aperture telescope based on **Extended‑Source Image (ESI) optimization**. ESI optimization enables in‑operation formation maintenance with observation‑wavelength precision by optimizing images of extended sources captured by the synthetic aperture telescope, without high‑precision absolute distance sensors.

The coordinate systems used in ESI optimization are shown in @fig:optical-coordinate.
$bold(u) = (u,v)$ denotes image‑sensor coordinates, and $bold(x) = (x,y)$ denotes aperture coordinates.

#figure(
  image("./img/coordinate/optics_coordinate_2.png"),
  caption: [Coordinate systems for the optical model @Suzumoto2023D],
) <fig:optical-coordinate>

Observation image synthesis in the algorithm is performed by convolving the true scene with the PSF obtained from the optical pupil. The PSF calculation is given in @eq:psf-calculation and @eq:psf-calculation-P.
When the relative position and attitude of mirror satellite $q$ are shifted by $bold(delta)_q$, the point‑source image (e.g., a star) is simulated, and the corresponding pixel intensities are computed. The wavefront aberration of the synthetic aperture system is computed from $bold(delta)_q$, and the point‑source PSF $s$ is

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

Below, we define the image features, describe the image‑feedback gradient method, characterize the ideal convergence state, and present the control algorithm.

== Features <sec:Feature>

- *Image Standard Deviation*  
  We use the standard deviation of pixel intensities as an evaluation function. A larger standard deviation indicates greater contrast and typically clearer images.

- *Image Power Spectral Density (PSD)*  
  We evaluate spatial resolution through the PSD, defined as the squared magnitude of the 2‑D Fourier spectrum of the image. The PSD distribution reveals the image’s spatial‑frequency content.

- *Wavefront Aberration of the Optical System*
  We track the wavefront aberration as a performance measure. Here, it refers to aberration caused by deviations in the mirror satellites’ relative position and attitude from the ideal configuration, with the Z‑axis position being the dominant contributor. Asmaller aberration indicates better optical performance.

== Extended Image‑Feedback Gradient Method <sec:Gradient>
In PSF‑based optimization, the relative position and attitude of the mirror satellites are updated along the gradient of an image‑derived evaluation function (“image‑feedback gradient”). A simple hill‑climbing scheme can be slow for ESI alone. We therefore extend the method to handle multiple mirror satellites using gradient descent with a momentum term, yielding faster convergence than the conventional approach. We refer to this as the **extended image‑feedback gradient method**.

== Ideal Convergence State <sec:Convergence>
Let @fig:true-image denote the true observation image (Earth’s surface). The ideal observation image in the final convergence state of ESI optimization is shown in @fig:planar-zero-W, and the corresponding PSF is shown in @fig:psf-zero-W. In this state, the maximum relative aberration between mirror satellites approaches zero; in particular, when all Z‑axis positions are consistent within the observation wavelength, the optical system is effectively ideal. For clarity, images are presented with a color map to visualize interference.

#figure(
  image("./data/sim_normal_6/test18_gray_256_256.png", height: 125pt),
  caption: [True observation image @Chiriin],
) <fig:true-image>

#grid(
    columns: 2,
    [#figure(
        image("./data/sim_normal_6/planar_zero_W.png"),
        caption: [Extended‑source image in the ideal state],
    ) <fig:planar-zero-W>
    ],
    [#figure(
        image("./data/sim_normal_6/psf_zero_W.png"),
        caption: [PSF of the synthetic aperture in the ideal state @fig:planar-zero-W],
    ) <fig:psf-zero-W>
    ],
)

== Control Algorithm <sec:Algorithm>
=== Initial State <ssec:Initial>
The initial wavefront aberration is shown in @fig:initial-W, indicating deviations of the mirror satellites from the ideal state. The maximum relative aberration is roughly an order of magnitude larger than the observation wavelength.

#figure(
  image("./data/sim_normal_6/initial_W.png", height: 150pt),
  caption: [Initial wavefront aberration of the mirror satellites],
) <fig:initial-W>

The corresponding ground image and PSF are shown in @fig:planar-initial and @fig:psf-initial, respectively. Compared with @fig:planar-zero-W and @fig:psf-zero-W, the initial ground image is blurred and the PSF is broadened due to the non‑ideal relative configuration.

#grid(
    columns: 2,
    [#figure(
        image("./data/sim_normal_6/planar_initial.png"),
        caption: [Initial extended‑source image],
    ) <fig:planar-initial>
    ],
    [#figure(
        image("./data/sim_normal_6/psf_initial.png"),
        caption: [Initial PSF of the synthetic aperture @fig:planar-initial],
    ) <fig:psf-initial>
    ],
)

=== Overlap Phase <ssec:Overlap>
In this phase, the images reflected by the mirror satellites and projected onto the imaging satellite are superimposed. The evaluation function is @eq:J-overlap, and the relative states are optimized using the extended image‑feedback gradient method.

$
J_"overlap" = "std"(I)
$ <eq:J-overlap>

By superimposing the mirror‑satellite projection images, we maximize the standard deviation (contrast) of the synthesized image. The resulting ground image and PSF are shown in @fig:planar-overlap and @fig:psf-overlap.

#grid(
    columns: 2,
    [#figure(
        image("./data/sim_normal_6/planar_overlap.png"),
        caption: [Image after the overlap phase],
    ) <fig:planar-overlap>
    ],
    [#figure(
        image("./data/sim_normal_6/psf_overlap.png"),
        caption: [PSF after the overlap phase @fig:planar-overlap],
    ) <fig:psf-overlap>
    ],
)

=== Interference‑Maximization (Z‑Search) Phase <ssec:Interference>
Next, we optimize each mirror satellite’s Z‑axis position to maximize interference, which in turn maximizes spatial resolution. The evaluation function is @eq:J-interference:

$
J_"interference" = sum_(bold(u)) abs(bold(u)) "PSD"(bold(u))
$ <eq:J-interference>

Here, $abs(bold(u))$ weights higher spatial frequencies (farther from the center of the 2‑D PSD). The ground image and PSF after this phase are shown in @fig:planar-interfere and @fig:psf-interfere, and the final wavefront aberration is in @fig:final-W.

#grid(
    columns: 2,
    [#figure(
        image("./data/sim_normal_6/planar_interfere.png"),
        caption: [Image after the interference search],
    ) <fig:planar-interfere>
    ],
    [#figure(
        image("./data/sim_normal_6/psf_interfere.png"),
        caption: [PSF after the interference search @fig:planar-interfere],
    ) <fig:psf-interfere>
    ],
)

#figure(
  image("./data/sim_normal_6/final_W.png", height: 150pt),
  caption: [Final wavefront aberration of the mirror satellites],
) <fig:final-W>

Compared with @fig:initial-W, the maximum relative aberration is reduced to a few wavelengths.

= Verification by Numerical Simulation <chap:Simulation>
We assess the algorithm’s validity using Monte Carlo simulations.
== Simulation Conditions <sec:Condition>
Simulation conditions are listed in @tab:simulation-condition. FFSAT has different specifications for summer and winter; here, we use the winter case.

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
    caption: [Simulation conditions],
) <tab:simulation-condition>

== Simulation Results <sec:SimulationResult>
The maximum relative aberration $W$ before and after applying ESI optimization is shown in @fig:W-before-and-after-ESI. Initially, $W approx 20$–$30$ (in units of the wavelength), and after applying ESI optimization, it is suppressed to about $W approx 1$–$3$. In some trials, however, the post‑control aberration exceeds $W > 70$, indicating convergence to a local optimum. Analysis shows that these cases share large initial aberration ($W > 40$). Thus, the current ESI method may fall into local optima when the initial aberration is large; further improvements to enlarge the convergence basin are warranted.

#figure(
  image("./data/sim_normal_6/W_before_and_after.png"),
  caption: [Maximum relative aberration before and after ESI optimization],
) <fig:W-before-and-after-ESI>

= Verification by Optical Experiment <chap:Experiment>
We perform control experiments with an optical setup that accounts for realistic effects such as imaging noise.
== Experiment Conditions <sec:ExperimentCondition>
An overview of the optical testbed is shown in @fig:testbed-overall and @fig:testbed-around-mirror.

#figure(
  image("./img/exp/IMG_9656_lr.jpg"),
  caption: [Overall view of the optical experiment system],
) <fig:testbed-overall>

#figure(
  image("./img/exp/IMG_9673_lr.jpg"),
  caption: [Mirror‑satellite section of the optical experiment system],
) <fig:testbed-around-mirror>

The system specifications are summarized in @tab:experiment-condition. Due to construction constraints, the number of mirrors and other parameters differ from FFSAT, but they suffice to verify the effectiveness of ESI optimization.

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
    caption: [Experiment conditions],
) <tab:experiment-condition>

The test chart in @fig:testchart is used as the true observation image.

#figure(
  image("./data/exp/testchart.png", height: 150pt),
  caption: [Test chart used in the optical experiment @TestChart],
) <fig:testchart>

A sample captured image is shown in @fig:testbed-image-sample.

#figure(
  image("./data/exp/0deg_gain=1_start_0.png"),
  caption: [Example captured image from the optical experiment],
) <fig:testbed-image-sample>

== Experiment Results <sec:ExperimentResult>
Results for each phase after applying ESI optimization are shown in @fig:testbed-result-all. In particular, the overlap phase visibly superimposes the mirror‑projection images. The captured images serve as control inputs, and the same evaluation functions as in the simulations are used.

#figure(
  image("./data/exp/result_all.png"),
  caption: [Captured images at each phase],
) <fig:testbed-result-all>

To confirm increased interference after the Z‑search phase, we compare the brightness distribution near the image center before and after control (@fig:testbed-center-before-ESI and @fig:testbed-center-after-ESI). These distributions correspond to the region marked by the red circle in the fourth image of @fig:testbed-result-all.

#figure(
  image("./data/exp/zoom_before.png"),
  caption: [Central‑region brightness distribution before control],
) <fig:testbed-center-before-ESI>

#figure(
  image("./data/exp/zoom_after.png"),
  caption: [Central‑region brightness distribution after control],
) <fig:testbed-center-after-ESI>

The post‑control distribution exhibits stronger modulation, indicating increased interference and hence improved spatial resolution.

= Application to Telescope‑Pointing Control <chap:Application>
In distributed optics such as FFSAT, the telescope pointing can be changed by independently moving each optical element. To minimize fuel consumption, we fix the imaging satellite’s position and change the pointing by actuating the mirrors on the mirror satellites (@fig:telescope-pointing-case3), rather than steering the formation’s center of gravity (@fig:telescope-pointing-case1) or assuming large sensors on the imaging satellite (@fig:telescope-pointing-case2). The key challenge is to execute this maneuver while maintaining the precise formation required for high‑resolution imaging. Two aspects are essential: (i) computing the required displacements for each mirror and (ii) controlling and correcting formation errors during and after the maneuver.

#figure(
  image("./img/telescope-pointing-case1.png"),
  caption: [Telescope‑pointing control method: case 1],
) <fig:telescope-pointing-case1>

#figure(
  image("./img/telescope-pointing-case2.png"),
  caption: [Telescope‑pointing control method: case 2],
) <fig:telescope-pointing-case2>

#figure(
  image("./img/telescope-pointing-case3.png"),
  caption: [Telescope‑pointing control method: case 3 (adopted)],
) <fig:telescope-pointing-case3>

First, we propose a method to compute mirror displacements for a desired pointing change. To minimize actuator travel, we proceed as follows:
1. Compute a new target paraboloid obtained by rotating the original paraboloid about the imaging satellite by the desired angle.
2. For each mirror’s current position on the original paraboloid, find the nearest point on the rotated paraboloid.
3. Compute the displacement vector between these positions and command the mirror motion.

Second, to correct formation errors that arise during re‑pointing, we evaluate two strategies incorporating ESI optimization in simulation:
- **Strategy A:** Apply a single feed‑forward pointing step using the computed displacements, then apply ESI optimization to restore the final formation shape and image quality.
- **Strategy B:** Execute the pointing change in multiple smaller steps, applying ESI optimization at each intermediate step to maintain accuracy throughout.

These approaches aim to maintain high‑spatial‑resolution imaging both before and after pointing changes, enabling flexible, continuous observations.

= Conclusion <chap:Conclusion>
We proposed **ESI optimization**, an image‑based method that controls the relative position and attitude of the optical system with respect to the imaging satellite at observation‑wavelength precision by optimizing extended‑source images. To accelerate convergence, we introduced an **extended image‑feedback gradient method** with momentum.

Through numerical simulations, we verified that—neglecting external disturbances—the relative position and attitude can be controlled with precision well beyond millimeter‑level capabilities typical of compact absolute‑distance sensors.

Experiments with an optical testbed confirmed that the method remains effective when using camera‑captured images.

Finally, we explored applying ESI optimization to telescope‑pointing sequences, demonstrating the potential to maintain the required formation accuracy during dynamic maneuvers such as target changes. This opens a path toward flexible and practical operation of FFSAT.

#bibliography("references.bib", title: "References", style: "american-institute-of-aeronautics-and-astronautics")
