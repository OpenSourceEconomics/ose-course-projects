########
Projects
########

Grading for `OSE data science <https://ose-data-science.readthedocs.io>`_ and `OSE scientific computing <https://ose-data-science.readthedocs.io>`_ is based on a group project due at the end of the semester, which should be presented in the form of a Jupyter Notebook. We encourage you to code your projects in Python, you may also use R or Julia. You can submit the project in the form of a GitHub repository or pull request on an existing repository (depending on your project).

You are free to select a topic of your choice related to the contents of the respective class. For example, you can either replicate the core results of a computational publication or apply for the chance to work on a collaboration project with one of our private sector partners. Other project ideas include running a benchmarking exercise for an algorithm, contributing to one of our group's software packages of your choice, or creating a notebook similar to the ones presented in the lectures on a computational topic that interests you. Note that several textbooks explore the implementation of involved computational economic models, porting their implementation to Python can serve as a valuable starting point for your project.

**Note for students taking EPP:**

Participants of the course "Effective Programming Practices for Economists" by Professor Hans-Martin von Gaudecker are welcome to submit their project for grading in `OSE data science <https://ose-data-science.readthedocs.io>`_ or `OSE scientific computing <https://ose-data-science.readthedocs.io>`_. Note that the project still has to fulfill the topic and submission requirements listed above in addition to any requirements stated by the EPP course. Please reach out in the course Zulip chat for any questions about the project.

===================
Kaggle Competitions
===================

`Kaggle <https://www.kaggle.com/>`_ hosts numerous (causal) machine learning tasks often sponsored by companies. In this context, a typical course project describes the competition you participated in and implements a version of your solution strategy. You can then, for example, explore the impact of alternative numerical components of your solution and investigate the effect of tuning parameters on its performance.

====================
Replication Projects
====================

You can replicate and extend a research article related to the topics of the course. A typical replication notebook starts with presenting the baseline article, reproducing selected key results, critical assessment of quality, and an independent contribution such as robustness check and visualizations. As a starting point for the introductory part of your notebook, please consider the recent article by Berk & al. (2017) on `How to Write an Effective Referee Report <https://www.aeaweb.org/articles?id=10.1257/jep.31.1.231>`_.

======================
Collaboration Projects
======================

Collaboration projects with our partners from the private sector allow students to directly put the skills acquired during class into action, gain hands-on experience in a professional data science setting, and receive feedback and mentoring from seasoned data scientists. Collaboration projects are announced in class, where we also provide further details about the application process.

================
Example Projects
================

--------------------
Replication Projects
--------------------

Here are some examples of replication projects from earlier iterations of the `OSE data science course <https://ose-data-science.readthedocs.io/en/latest/index.html>`_.

Angrist (1990)
""""""""""""""

The randomly assigned risk of induction generated by the draft lottery is used to construct estimates of the effect of veteran status on civilian earnings. These estimates are not biased by the fact that certain types of men are more likely than others to service in  the military. Social Security administrative records indicate that in the early  1980s, long  after  their service  in  Vietnam was ended, the earnings of white veterans were approximately 15 percent less than the earnings of comparable nonveterans.

Project by `Pascal Heid <https://github.com/Pascalheid>`_

.. toctree::
   :maxdepth: 1

   Angrist_1990/Angrist_1990

Lindo et al. (2010)
"""""""""""""""""""

Lindo et al. (2010) examine the effects of academic probation on student outcomes using a regression discontinuity design. The analysis is based on data from a large Canadian university and evaluates whether academic probation is successful in improving the performance of low scoring students. Consistent with a model of performance standards, the authors find that being placed on probation in the first year of university induces some students to drop out of school while it improves the grades of students who continue their studies. In a more general sense, academic probation can offer insights into how agents respond to negative incentives and the threat of punishment in a real-world context.

Project by `Annica Gehlen <https://github.com/amageh>`_

.. toctree::
   :maxdepth: 1

   Lindo_et_al_2010/project

----------------------
Collaboration Projects
----------------------

Examples of collaboration projects with Daimler AG and Deutsch Bank organized in a previous iteration of the `OSE data science course <https://ose-data-science.readthedocs.io/en/latest/index.html>`_ are available below.

Daimler AG
""""""""""

The main focus of this project is to develop a procedure to identify abnormal observations in sensor data collected during production processes. Each data point can be interpreted as a set of points where a function was observed. Therefore, the whole problem can be approached from a standpoint of outlier classification in functional data.

Project by `Jakob Juergens <https://github.com/JakobJuergens>`_

.. toctree::
   :maxdepth: 1

   daimler-project/Project-Main

Deutsche Bank
"""""""""""""

The Deutsche Bank project uses different modern Machine Learning (ML) methods to detect so-called regret credits, which can be considered as credits that become deficient at some point in time. The project???s scope is to develop AI-related models that can determine the regret-probability of credits and assign it to certain characteristics. One challenge is to shed light on the so-called black-box, where even the AI developers do not know why their AIs make certain decisions. Another challenge is to design the model such that it provides precise results although the data set is imbalanced, that is, it contains many more non-regret credits than regret credits. Moreover, data visualizations are performed to support the result's content to finally present them to the stakeholders.

Project by `Arbi Kodraj <https://github.com/ArbiKodraj>`_

.. toctree::
   :maxdepth: 1

   deutsch-bank/db-project
