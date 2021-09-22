###############
Reproducibility
###############

To ensure full reproducibility of your project, please try to set up a `GitHub Actions CI <https://docs.github.com/en/actions/>`_  as your continuous integration service. An introductory tutorial for `conda <https://conda.io/>`_ and `GitHub Actions <https://docs.github.com/en/actions/learn-github-actions/introduction-to-github-actions/>`_ is provided
`here <https://github.com/OpenSourceEconomics/ose-template-course-project/blob/master/tutorial_conda_actions.ipynb/>`_. While not at all mandatory, setting up a proper continuous integration workflow is an extra credit that can improve your final grade.

If, for example, the computation of results takes multiple hours, you might not be able to run parts of your code on `GitHub Actions CI <https://docs.github.com/en/actions/>`_. In such cases you can add the result in a file to your repository and load it in the notebook. See below for an example code.

.. code-block:: python

  # If we are running on GitHub Actions CI we will simply load a file with existing results.

  if os.environ.get("CI") == "true":
      rslt = pkl.load(open("stored_results.pkl", "br"))
  else:
      rslt = compute_results()

  # Now we are ready for further processing.

However, if you decide to do so, please be sure to provide an explanation in your notebook explaining why exactly this is required in your case.
