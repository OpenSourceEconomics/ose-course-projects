########
Projects
########

Grading for `OSE data science <https://ose-data-science.readthedocs.io>`_ and `OSE scientific computing <https://ose-data-science.readthedocs.io>`_ is based on a project due at the end of the semester, which should be presented in the form of a Jupyter Notebook. Although I encourage you to code your projects in Python, you may also use R or Julia. You can work on your project using the `Nuvolos.cloud <https://nuvolos.cloud>`_  and share it with Professor Eisenhauer for grading. Alternatively, you can submit the project in the form of a GitHub repository or pull request on an existing repository (depending on your project). Reproducibility is a cornerstone of sound computational work, so please ensure that we can run your project notebook from beginning to end without any error. Please discuss your project idea with Professor Eisenhauer.

You are free to select a topic of your choice related to the contents of the respective  class. For example, you can either replicate the core results of a computational publication or apply for the chance to work on a collaboration project with one of our private sector partners. Other project ideas include running a benchmarking exercise for an algorithm, contributing to one of our group's software packages of your choice, or creating a notebook similar to the ones presented in the lectures on a computational topic that interests you. Note that several textbooks explore the implementation of involved computational economic models, porting their implementation to Python can serve as a valuable starting point for your project.

**Note for students taking EPP:**
Participants of the course "Effective Programming Practices for Economists" by Professor Hans-Martin von Gaudecker are welcome to submit their project for grading in `OSE data science <https://ose-data-science.readthedocs.io>`_ or `OSE scientific computing <https://ose-data-science.readthedocs.io>`_. Note that the project still has to fulfill the topic and submission requirements listed above in addition to any requirements stated by the EPP course. Please reach out in the course Zulip chat for any questions about the project. 

Make sure you subscribe to the `OSE course project stream <https://bonn-econ-teaching.zulipchat.com/#narrow/stream/300796-OSE-Course.20Projects>`_ in the bonn-econ-teaching `Zulip <https://zulip.com/>`_ chat, where you can post any questions you may have regarding your course project.

===================
Kaggle Competitions
===================

*investigate tuning parameter, identify the numerical components in the algorithm, swap-in-swap out components underlying assumptions for prediction / causal model to work*

====================
Replication Projects
====================

A typical replication notebook has the following structure:

* presentation of baseline article with proper citation and brief summary

* using causal graphs to illustrate the authors' identification strategy

* replication of selected key results

* critical assessment of quality

* independent contribution, e.g. additional external evidence, robustness checks, visualization

There might be good reason to deviate from this structure. If so, please simply document your reasoning and go ahead. Please use the opportunity to review other student projects for some inspiration as well.

======================
Collaboration Projects
======================

Collaboration projects with our partners from the private sector allow students to directly put the skills acquired during class into action, gain hands-on experience in a professional data science setting, and receive feedback and mentoring from seasoned data scientists. Collaboration projects are announced in class, where we also provide further details about the application process.

----------
Daimler AG
----------

This project is about finding (and applying) methods to identify anomalies and abnormal observations in production processes. Provided with datasets by Daimler AG, the task of the student is to explore the datasets and their respective structures. Based on these insights, the student must choose appropriate methods to conduct an anomaly analysis, i.e., find (groups of) observations that differ significantly from the normal case.

The main focus of the project is to compare different methods and to discuss the advantages and disadvantages with respect to their theoretical assumptions and their practical implications (e.g., computational costs). In this context, it is noteworthy that Daimler AG is interested in applying the methods provided by the student to different datasets after the project has been submitted. Consequently, reproducibility and setting up a flexible data workflow is a core requirement of the project. While guiding literature is provided, the choice of methodology is up to the student. Therefore, methods applied can range from traditional econometric time series analyses to the application of machine- and deep learning techniques.

Overall, the project enables the student to learn about the use cases of data analysis in a corporate environment and get hands-on experience in a professional data science setting. Through supervisory meetings with Daimler AG the student additionally has the chance to get feedback and insights from professional data scientists and learn about their work.

A collaboration project with Daimler AG from the `OSE data science course <https://ose-data-science.readthedocs.io/en/latest/index.html>`_ held during the 2021 summer semester is available here:   

--------------
Deutsche Bank
--------------

The Deutsche Bank project uses different modern Machine Learning (ML) methods to detect so-called regret credits, which can be considered as credits that become deficient at some point in time. Initial data sets are provided by Deutsche Bank AG and processed by the student for the final analysis. The student develops appropriate ML models based on the information content of the data set. If necessary, ensemble methods are used to obtain better predictive performance than could be obtained from any of the constituent learning algorithms alone. Moreover, data visualizations are performed to support the result's content to finally present them to the stakeholders.

The project’s scope is to develop AI-related models that can determine the regret-probability of credits and assign it to certain characteristics. Programming-heavy and model-oriented, it emphasizes the reproducibility of results, as the AI will be used internally in the long term. One challenge is to shed light on the so-called black-box, where even the AI developers do not know why their AIs make certain decisions. In light of the project's scope, this means to better understand why the AI assigns a certain probability of being conspicuous to a specific credit. Another challenge is to design the model such that it provides precise results although the data set is imbalanced, that is, it contains many more non-regret credits than regret credits.  

In general, the project exposes the student to research on how to improve classifications with imbalanced datasets, as this type of data can be found in many real-world applications. Finally, developing an AI-related model facing the issue of explainability is particularly innovative for the banking sector and thus allows the student to contribute in a project that aims to apply cutting edge statistical methods. 
