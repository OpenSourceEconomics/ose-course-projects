"""This module contains auxiliary functions for RD predictions used in the main notebook."""
import json

import matplotlib as plt
import pandas as pd
import numpy as np
import statsmodels as sm

from auxiliary.example_project_auxiliary_predictions import *
from auxiliary.example_project_auxiliary_plots import *
from auxiliary.example_project_auxiliary_tables import *

def prepare_data(data):
    """
    Adds variables needed for analysis to data.
    """
    # Add constant to data to use in regressions later.
    data.loc[:, "const"] = 1

    # Add dummy for being above the cutoff in next GPA
    data["nextGPA_above_cutoff"] = np.NaN
    data.loc[data.nextGPA >= 0, "nextGPA_above_cutoff"] = 1
    data.loc[data.nextGPA < 0, "nextGPA_above_cutoff"] = 0

    # Add dummy for cumulative GPA being above the cutoff
    data["nextCGPA_above_cutoff"] = np.NaN
    data.loc[data.nextCGPA >= 0, "nextCGPA_above_cutoff"] = 1
    data.loc[data.nextCGPA < 0, "nextCGPA_above_cutoff"] = 0

    # Remove zeros from total credits for people whose next GPA is missing
    data["total_credits_year2"] = data["totcredits_year2"]
    data.loc[np.isnan(data.nextGPA) == True, "total_credits_year2"] = np.NaN
    # Add variable for campus specific cutoff
    data["cutoff"] = 1.5
    data.loc[data.loc_campus3 == 1, "cutoff"] = 1.6

    return data


def calculate_bin_frequency(data, bins):
    """
    Calculates the frequency of different bins in a dataframe.

    Args:
    ------
        data(pd.DataFrame): Dataframe that contains the raw data.
        bins(column): Name of column that contains the variable that should be assessed.

    Returns:
    ---------
        bin_frequency(pd.DataFrame): Dataframe that contains the frequency of each bin in data and and a constant.
    """
    bin_frequency = pd.DataFrame(data[bins].value_counts())
    bin_frequency.reset_index(level=0, inplace=True)
    bin_frequency.rename(columns={"index": "bins", bins: "freq"}, inplace=True)
    bin_frequency = bin_frequency.sort_values(by=["bins"])
    bin_frequency["const"] = 1

    return bin_frequency


def create_groups_dict(data, keys, columns):
    """
    Function creates a dictionary containing different subsets of a dataset. Subsets are created using dummies. 

    Args:
    ------
        data(pd.DataFrame): Dataset that should be split into subsets.
        keys(list): List of keys that should be used in the dataframe.
        columns(list): List of dummy variables in dataset that are used for creating subsets.

    Returns:
    ---------
        groups_dict(dictionary)
    """
    groups_dict = {}

    for i in range(len(keys)):
        groups_dict[keys[i]] = data[data[columns[i]] == 1]

    return groups_dict


def create_predictions(data, outcome, regressors, bandwidth):
    
    steps = np.arange(-1.2, 1.25, 0.05)
    predictions_df = pd.DataFrame([])
    # Ensure there are no missings in the outcome variable.
    data = data.dropna(subset=[outcome])
    # Loop through bins or 'steps'.
    for step in steps:
        df = data[(data.dist_from_cut >= (step - bandwidth)) &
                  (data.dist_from_cut <= (step + bandwidth))]
        # Run regression for with all values in the range specified above.
        model = sm.regression.linear_model.OLS(
            df[outcome], df[regressors], hasconst=True)
        result = model.fit(cov_type='cluster', cov_kwds={
                           'groups': df['clustervar']})

        # Fill in row for each step in the prediction datframe.
        predictions_df.loc[step, 'dist_from_cut'] = step
        if step < 0:
            predictions_df.loc[step, 'gpalscutoff'] = 1
        else:
            predictions_df.loc[step, 'gpalscutoff'] = 0

        predictions_df.loc[step, 'gpaXgpalscutoff'] = (
            predictions_df.loc[step, 'dist_from_cut']) * predictions_df.loc[step, 'gpalscutoff']
        predictions_df.loc[step, 'gpaXgpagrcutoff'] = (predictions_df.loc[
                                                       step, 'dist_from_cut']) * (1 - predictions_df.loc[step, 'gpalscutoff'])
        predictions_df.loc[step, 'const'] = 1

        # Make prediction for each step based on regression of each step and
        # save value in the prediction dataframe.
        predictions_df.loc[step, 'prediction'] = result.predict(exog=[[
            predictions_df.loc[step, 'const'],
            predictions_df.loc[step, 'gpalscutoff'],
            predictions_df.loc[step, 'gpaXgpalscutoff'],
            predictions_df.loc[step, 'gpaXgpagrcutoff']
        ]])

    predictions_df.round(4)

    return predictions_df


def create_bin_frequency_predictions(data, steps, bandwidth):
    """
    
    """
    predictions_df = pd.DataFrame([])
    # Loop through bins or 'steps'.
    for step in steps:
        df = data[(data.bins >= (step - bandwidth)) &
                  (data.bins <= (step + bandwidth))]
        # Run regression for with all values in the range specified above.
        model = sm.regression.linear_model.OLS(
            df['freq'], df[['const', 'bins']], hasconst=True)
        result = model.fit()

        # Fill in row for each step in the prediction datframe.
        predictions_df.loc[step, 'bins'] = step
        predictions_df.loc[step, 'const'] = 1
        predictions_df.loc[step, 'prediction'] = result.predict(exog=[[predictions_df.loc[step, 'const'],
                                                                       predictions_df.loc[
                                                                           step, 'bins'],
                                                                       ]])

    predictions_df.round(4)

    return predictions_df


def create_fig3_predictions(groups_dict, regressors, bandwidth):
    """
    Compute predicted outcomes for figure 3.
    """
    
    predictions_groups_dict = {}
    # Loop through groups:
    for group in groups_dict:

        steps = np.arange(-1.2, 1.25, 0.05)
        predictions_df = pd.DataFrame([])

        # Loop through bins or 'steps'.
        for step in steps:
            # Select dataframe from the dictionary.
            df = groups_dict[group][(groups_dict[group].dist_from_cut >= (step - bandwidth)) &
                                    (groups_dict[group].dist_from_cut <= (step + bandwidth))]
            # Run regression for with all values in the range specified above.
            model = sm.regression.linear_model.OLS(
                df['left_school'], df[regressors], hasconst=True)
            result = model.fit(cov_type='cluster', cov_kwds={
                               'groups': df['clustervar']})

            # Fill in row for each step in the prediction datframe.
            predictions_df.loc[step, 'dist_from_cut'] = step
            if step < 0:
                predictions_df.loc[step, 'gpalscutoff'] = 1
            else:
                predictions_df.loc[step, 'gpalscutoff'] = 0

            predictions_df.loc[step, 'gpaXgpalscutoff'] = (
                predictions_df.loc[step, 'dist_from_cut']) * predictions_df.loc[step, 'gpalscutoff']
            
            predictions_df.loc[step, 'gpaXgpagrcutoff'] = (
                predictions_df.loc[step, 'dist_from_cut']) * (1 - predictions_df.loc[step, 'gpalscutoff'])
            predictions_df.loc[step, 'const'] = 1

            # Make prediction for each step based on regression of each step
            # and save value in the prediction dataframe.
            predictions_df.loc[step, 'prediction'] = result.predict(exog=[[
                predictions_df.loc[step, 'const'],
                predictions_df.loc[step, 'gpalscutoff'],
                predictions_df.loc[step, 'gpaXgpalscutoff'],
                predictions_df.loc[step, 'gpaXgpagrcutoff']
            ]])

            predictions_df = predictions_df.round(4)
            
        # Save the predictions for all groups in a dictionary.
        predictions_groups_dict[group] = predictions_df

    return predictions_groups_dict


def bootstrap_predictions(n, data, outcome, regressors, bandwidth):
    """
    Compute predicted outcome from bootstrap with replacement.
    """
    bootstrap_pred = pd.DataFrame({})
    for i in range(0, n):
        bootstrap = data.sample(n=len(data), replace=True)
        pred = create_predictions(
            data=bootstrap, outcome=outcome, regressors=regressors, bandwidth=bandwidth)
        bootstrap_pred['pred_' + str(i)] = pred.prediction
        i = +1
    return bootstrap_pred


def get_confidence_interval(data, lbound, ubound, index_var):
    """
    Compute confidence interval from data of bootstrapped predictions.
    """
    confidence_interval = pd.DataFrame({})
    for i in data.index:
        confidence_interval.loc[i, "lower_bound"] = np.percentile(data.loc[
                                                                  i, :], lbound)
        confidence_interval.loc[i, "upper_bound"] = np.percentile(data.loc[
                                                                  i, :], ubound)

    confidence_interval[index_var] = confidence_interval.index 
    
    return confidence_interval

def bandwidth_sensitivity_summary(
    data, outcome, groups_dict_keys, groups_dict_columns, regressors
):
    """
    Creates table that summarizes the results for the analysis of bandwidth sensitivity.
    """
    #from auxiliary.auxiliary_tables import estimate_RDD_multiple_datasets

    bandwidths = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 1.1, 1.2]
    arrays = [
        np.array([0.1, 0.1, 0.2, 0.2, 0.3, 0.3, 0.4, 0.4,
                  0.5, 0.5, 0.6, 0.6, 0.7, 0.7, 0.8, 0.8,
                  0.9, 0.9, 1, 1, 1.1, 1.1, 1.2, 1.2, ]
                 ),
        np.array(["probation", "p-value"] * 12),
    ]

    summary = pd.DataFrame(index=arrays, columns=groups_dict_keys)

    for val in bandwidths:
        sample = data[abs(data["dist_from_cut"]) < val]
        groups_dict = create_groups_dict(
            sample, groups_dict_keys, groups_dict_columns)
        table = estimate_RDD_multiple_datasets(
            groups_dict, groups_dict_keys, outcome, regressors
        )
        summary.loc[(val, "probation"), :] = table["GPA below cutoff (1)"]
        summary.loc[(val, "p-value"), :] = table["P-Value (1)"]

        for i in summary.columns:
            if (summary.loc[(val, "p-value"), i] < 0.1) == False:
                summary.loc[(val, "p-value"), i] = "."
                summary.loc[(val, "probation"), i] = "x"

    return summary


def trim_data(groups_dict, trim_perc, case1, case2):
    """ Creates trimmed data for upper and lower bound analysis by trimming the top and bottom percent of 
    students from control or treatment group. This can be used for the upper bound and lower bound. 
    * For lower bound use `case1 = True` and `case2 = False`
    * For upper bound use `case1 = False` and `case2 = True`.

    Args:
    --------
        groups_dict(dictionary): Dictionary that holds all datasets that should be trimmed.
        trim_perc(pd.Series/pd.DataFrame): Series oder dataframe that for each dataset in groups dict specifies
                                           how much should be trimmed.
        case1(True or False): Specifies whether lower or upper bound should be trimmed in the case where the the trimamount
                              is positive and the control group is trimmed.
        case2(True or False): Specifies whether lower or upper bound should be trimmed in the case where the the trimamount
                              is negative and the treatment group is trimmed.

    Returns:
    ---------
        trimmed_dict(dictionary): Dictionary holding the trimmed datasets.
    """

    trimmed_dict = {}
    for key in groups_dict.keys():
        # Create data to be trimmed
        data = groups_dict[key].copy()
        control = data[data.dist_from_cut >= 0].copy()
        treat = data[data.dist_from_cut < 0].copy()

        trimamount = float(trim_perc[key])

        # Trim control group
        if trimamount > 0:
            n = round(len(control[control.left_school == 1]) * trimamount)
            control.sort_values("nextGPA", inplace=True, ascending=case1)
            trimmed_students = control.iloc[0:n]
            trimmed_students_ids = list(trimmed_students.identifier)
            trimmed_control = control[
                control.identifier.isin(trimmed_students_ids) == False
            ]
            df = pd.concat([trimmed_control, treat], axis=0)

        # If the trim amount is negative, we need to trim the treatment instead
        # of the control group.
        elif trimamount < 0:
            trimamount = abs(trimamount)
            n = round(len(treat[treat.left_school == 1]) * trimamount)
            treat.sort_values("nextGPA", inplace=True, ascending=case2)
            trimmed_students = treat.iloc[0:n]
            trimmed_students_ids = list(trimmed_students.identifier)
            trimmed_treat = treat[treat.identifier.isin(
                trimmed_students_ids) == False]
            df = pd.concat([trimmed_treat, control], axis=0)

        trimmed_dict[key] = df

    return trimmed_dict