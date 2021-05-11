"""This module contains auxiliary functions for plotting which are used in the main notebook."""

import matplotlib as plt
import pandas as pd
import numpy as np
import statsmodels as sm

from auxiliary.example_project_auxiliary_predictions import *
from auxiliary.example_project_auxiliary_plots import *
from auxiliary.example_project_auxiliary_tables import *

def plot_RDD_curve(df, running_variable, outcome, cutoff):
    """ Function to plot RDD curves. Function splits dataset into treated and untreated group based on running variable
        and plots outcome (group below cutoff is treated, group above cutoff is untreated).

        Args:
        -------
            df(DataFrame): Dataframe containing the data to be plotted.
            running_variable(column): DataFrame column name of the running variable.
            outome(column): DataFrame column name of the outcome variable.
            cutoff(numeric): Value of cutoff.

        Returns:
        ---------
            matplotlib.pyplpt.plot
    """
    plt.pyplot.grid(True)
    df_treat = df[df[running_variable] < cutoff]
    df_untreat = df[df[running_variable] >= cutoff]
    plt.pyplot.plot(df_treat[outcome])
    plt.pyplot.plot(df_untreat[outcome])

    return


def plot_RDD_curve_colored(df, running_variable, outcome, cutoff, color):
    """ Function to plot RDD curves. Function splits dataset into treated and untreated group based on running variable
        and plots outcome (group below cutoff is treated, group above cutoff is untreated).

        Args:
        -------
            df(DataFrame): Dataframe containing the data to be plotted.
            running_variable(column): DataFrame column name of the running variable.
            outome(column): DataFrame column name of the outcome variable.
            cutoff(numeric): Value of cutoff.

        Returns:
        ---------
            matplotlib.pyplpt.plot

    """
    plt.pyplot.grid(True)
    df_treat = df[df[running_variable] < cutoff]
    df_untreat = df[df[running_variable] >= cutoff]
    plt.pyplot.plot(
        df_treat[outcome],
        color=color,
        label='_nolegend_'
    )
    plt.pyplot.plot(
        df_untreat[outcome],
        color=color,
        label='_nolegend_')


def plot_RDD_curve_CI(df, running_variable, outcome, cutoff, lbound, ubound, CI_color, linecolor):
    """ Function to plot RDD curves with confidence intervals. Function splits dataset into treated and 
        untreated group based on running variable and plots outcome (group below cutoff is treated, group above 
        cutoff is untreated).

        Args:
        ------
            df(DataFrame): Dataframe containing the data to be plotted.
            running_variable(column): DataFrame column name of the running variable.
            outome(column): DataFrame column name of the outcome variable.
            cutoff(numeric): Value of cutoff.
            lbound(column): Lower bound of confidence interval.
            ubound(column): Upper bound of confidence interval.


        Returns:
        ----------
            matplotlib.pyplpt.plot

    """
    plt.pyplot.grid(True)
    df_treat = df[df[running_variable] < cutoff]
    df_untreat = df[df[running_variable] >= cutoff]

    # Plot confidence Intervals.
    plt.pyplot.plot(df_treat[lbound], color=CI_color, alpha=0.3)
    plt.pyplot.plot(df_treat[ubound], color=CI_color, alpha=0.3)
    plt.pyplot.plot(df_untreat[lbound], color=CI_color, alpha=0.3)
    plt.pyplot.plot(df_untreat[ubound], color=CI_color, alpha=0.3)
    plt.pyplot.fill_between(df_treat[running_variable],
                            y1=df_treat[lbound],
                            y2=df_treat[ubound],
                            facecolor=CI_color,
                            alpha=0.3
                            )
    plt.pyplot.fill_between(df_untreat[running_variable],
                            y1=df_untreat[lbound],
                            y2=df_untreat[ubound],
                            facecolor=CI_color,
                            alpha=0.3
                            )

    # Plot estimated lines.
    plt.pyplot.plot(df_untreat[outcome],
                    color=linecolor,
                    label='_nolegend_'
                    )
    plt.pyplot.plot(df_treat[outcome],
                    color=linecolor,
                    label='_nolegend_')
    

def plot_hist_GPA(data):
    """
    Plots historgram showing the distribution of stuents according to distance
    from fist year cutoff.
    """
    plt.pyplot.xlim(-1.8, 3)
    plt.pyplot.ylim(0, 3500)
    plt.pyplot.xticks([-1.2, -0.6, 0, 0.6, 1.2, 1.8, 2.4, 3])
    plt.pyplot.hist(data['dist_from_cut'], bins=30, color='orange', alpha=0.7)
    plt.pyplot.axvline(x=-1.2, color='c', alpha=0.8)
    plt.pyplot.axvline(x=1.2, color='c', alpha=0.8)
    plt.pyplot.axvline(x=0.6, color='c', alpha=0.3)
    plt.pyplot.axvline(x=-0.6, color='c', alpha=0.3)
    plt.pyplot.axvline(x=0, color='r')
    plt.pyplot.fill_betweenx(y=range(3500), x1=-1.8,
                             x2=-1.2, alpha=0.8, facecolor='c')
    plt.pyplot.fill_betweenx(y=range(3500), x1=-1.2,
                             x2=-0.6, alpha=0.3, facecolor='c')
    plt.pyplot.fill_betweenx(y=range(3500), x1=1.2,
                             x2=0.6, alpha=0.3, facecolor='c')
    plt.pyplot.fill_betweenx(
        y=range(3500), x1=3, x2=1.2, alpha=0.8, facecolor='c')
    plt.pyplot.xlabel('First year GPA minus probation cutoff')
    plt.pyplot.ylabel('Freq.')
    plt.pyplot.title('Distribution of student GPAs distance from the cutoff')


def plot_covariates(data, descriptive_table, bins):
    """
    Plots covariates with bins of size 0.5 grade points.
    """
    plt.pyplot.figure(figsize=(13, 10), dpi=70, facecolor='w', edgecolor='k')
    plt.pyplot.subplots_adjust(wspace=0.2, hspace=0.4)

    for idx, var in enumerate(descriptive_table.index):
        plt.pyplot.subplot(3, 3, idx + 1)
        plt.pyplot.axvline(x=0, color='r')
        plt.pyplot.grid(True)
        plt.pyplot.plot(data[var].groupby(
            data['dist_from_cut_med05']).mean(), 'o', color='c', alpha=0.5)
        plt.pyplot.xlabel('Distance from cutoff')
        plt.pyplot.ylabel('Mean')
        plt.pyplot.title(descriptive_table.iloc[idx, 4])


def plot_figure1(data, bins, pred):
    """
    Plots Figure 1.

    Args:
    ------
        data(pd.DataFrame): Dataframe containing the frequency of each bin.
        bins(list): List of bins.
        pred(pd.DataFrame): Predicted frequency of each bin.

    Returns:
    ---------
        matplotlib.pyplpt.plot
    """
    plt.pyplot.xlim(-1.5, 1.5, 0.1)
    plt.pyplot.ylim(0, 2100.5, 50)
    plt.pyplot.axvline(x=0, color='r')
    plt.pyplot.xlabel('First year GPA minus probation cutoff')
    plt.pyplot.ylabel('Frequency count')
    plt.pyplot.plot(data.bins, data.freq, 'o')
    plot_RDD_curve(df=pred, running_variable="bins",
                   outcome="prediction", cutoff=0)
    plt.pyplot.title(
        "Figure 1. Distribution of Student Grades Relative to their Cutoff")


def plot_figure2(data, pred):
    """
    Plots Figure 2.
    """
    plt.pyplot.xlim(-1.5, 1.5, 0.1)
    plt.pyplot.plot(data['dist_from_cut_med10'], data['gpalscutoff'], 'o')
    plot_RDD_curve(df=pred, running_variable="dist_from_cut",
                   outcome="prediction", cutoff=0)
    plt.pyplot.axvline(x=0, color='r')
    plt.pyplot.title('Figure 2: Porbation Status at the end of first year')
    plt.pyplot.xlabel('First year GPA minus probation cutoff')
    plt.pyplot.ylabel('Probation Status')


def plot_figure3(inputs_dict, outputs_dict, keys):
    """ Plot results from RD anlaysis for the six subgroups of students in the paper for Figure3.

    Args:
    -------
        inputs_dict(dict): Dictionary containing all dataframes for each subgroup, used for plotting the bins (dots).
        outputs_dict(dict): Dictionary containing the results from RD analysis for each subgroup, used for plotting the lines.
        keys(list): List of keys of the dictionaries, both dictionaries must have the same keys.

    Returns:
    ----------
        matplotlib.pyplpt.plot: Figure 3 from the paper (figure consists of 6 subplots, one for each subgroup of students)
    """
    # Frame for entire figure.
    plt.pyplot.figure(figsize=(10, 13), dpi=70, facecolor='w', edgecolor='k')
    plt.pyplot.subplots_adjust(wspace=0.4, hspace=0.4)

    # Remove dataframe 'All' because I only want to plot the results for the
    # subgroups of students.
    keys = keys.copy()
    keys.remove('All')

    # Create plots for all subgroups.
    for idx, key in enumerate(keys):
        # Define position of subplot.
        plt.pyplot.subplot(3, 2, idx + 1)
        # Create frame for subplot.
        plt.pyplot.xlim(-1.5, 1.5, 0.1)
        plt.pyplot.ylim(0, 0.22, 0.1)
        plt.pyplot.axvline(x=0, color='r')
        plt.pyplot.xlabel('First year GPA minus probation cutoff')
        plt.pyplot.ylabel('Left university voluntarily')
        # Calculate bin means.
        bin_means = inputs_dict[key].left_school.groupby(
            inputs_dict[key]['dist_from_cut_med10']).mean()
        bin_means = pd.Series.to_frame(bin_means)
        # Plot subplot.
        plt.pyplot.plot(list(bin_means.index),
                        list(bin_means.left_school), 'o')
        plot_RDD_curve(
            df=outputs_dict[key],
            running_variable="dist_from_cut",
            outcome="prediction",
            cutoff=0
        )
        plt.pyplot.title(key)


def plot_figure4(data, pred):
    """
    Plots Figure 4.
    """
    plt.pyplot.figure(figsize=(8, 5))
    plt.pyplot.xlim(-1.5, 1.5, 0.1)
    plt.pyplot.ylim(-1, 1.5, 0.1)
    plt.pyplot.axvline(x=0, color='r')
    plt.pyplot.xlabel('First year GPA minus probation cutoff')
    plt.pyplot.ylabel('Subsequent GPA minus Cutoff')
    plt.pyplot.plot(data.nextGPA.groupby(
        data['dist_from_cut_med10']).mean(), 'o')
    plot_RDD_curve(df=pred, running_variable="dist_from_cut",
                   outcome="prediction", cutoff=0)
    plt.pyplot.title("Figure 4 - GPA in the next enrolled term")


def plot_figure5(data, pred_1, pred_2, pred_3):
    """
    Plots Figure 5.
    """
    plt.pyplot.figure(figsize=(8, 5))
    plt.pyplot.xlim(-1.5, 1.5, 0.1)
    plt.pyplot.ylim(0, 1, 0.1)
    plt.pyplot.axvline(x=0, color='r')
    plt.pyplot.xlabel('First year GPA minus probation cutoff')
    plt.pyplot.ylabel('Has Graduated')

    plt.pyplot.plot(data.gradin4.groupby(
        data['dist_from_cut_med10']).mean(), 'o', color='k', label='Within 4 years')
    plot_RDD_curve_colored(df=pred_1,
                           running_variable="dist_from_cut",
                           outcome="prediction",
                           cutoff=0,
                           color='k'
                           )

    plt.pyplot.plot(data.gradin5.groupby(data['dist_from_cut_med10']).mean(),
                    'x',
                    color='C0',
                    label='Within 5 years'
                    )
    plot_RDD_curve_colored(df=pred_2,
                           running_variable="dist_from_cut",
                           outcome="prediction",
                           cutoff=0,
                           color='C0'
                           )

    plt.pyplot.plot(data.gradin6.groupby(data['dist_from_cut_med10']).mean(),
                    '^',
                    color='g',
                    label='Within 6 years'
                    )
    plot_RDD_curve_colored(df=pred_3,
                           running_variable="dist_from_cut",
                           outcome="prediction",
                           cutoff=0,
                           color='g'
                           )

    plt.pyplot.legend()
    plt.pyplot.title("Figure 5 - Graduation Rates")


def plot_figure4_with_CI(data, pred):
    """
    Plots Figure 4 with confidence intervals.
    """
    plt.pyplot.figure(figsize=(8, 6))
    plt.pyplot.xlim(-1.5, 1.5, 0.1)
    plt.pyplot.ylim(-0.5, 1.2, 0.1)
    plt.pyplot.axvline(x=0, color='r')
    plt.pyplot.xlabel('First year GPA minus probation cutoff')
    plt.pyplot.ylabel('Subsequent GPA minus Cutoff')
    plt.pyplot.plot(data.nextGPA.groupby(
        data['dist_from_cut_med10']).mean(), 'o')
    plot_RDD_curve_CI(df=pred,
                      running_variable="dist_from_cut",
                      outcome="prediction",
                      cutoff=0,
                      lbound='lower_bound',
                      ubound='upper_bound',
                      CI_color='c',
                      linecolor='orange'
                      )

    plt.pyplot.title("GPA in the next enrolled term with CI")


def plot_figure_credits_year2(data, pred):
    plt.pyplot.figure(figsize=(8, 5))
    plt.pyplot.xlim(-1.5, 1.5, 0.1)
    plt.pyplot.ylim(2.5, 5, 0.1)
    plt.pyplot.axvline(x=0, color='r')
    plt.pyplot.xlabel('First year GPA minus probation cutoff')
    plt.pyplot.ylabel('Total credits in year 2')
    plt.pyplot.plot(data.total_credits_year2.groupby(
        data['dist_from_cut_med10']).mean(), 'o')
    plot_RDD_curve(df=pred, running_variable="dist_from_cut",
                   outcome="prediction", cutoff=0)
    plt.pyplot.title("Total credits in Second Year")


def plot_left_school_all(data, pred):
    plt.pyplot.xlim(-1.5, 1.5, 0.1)
    plt.pyplot.ylim(0, 0.22, 0.1)
    plt.pyplot.axvline(x=0, color='r')
    plt.pyplot.xlabel('First year GPA minus probation cutoff')
    plt.pyplot.ylabel('Left university voluntarily')

    bin_means = data.left_school.groupby(data['dist_from_cut_med10']).mean()
    bin_means = pd.Series.to_frame(bin_means)
    plt.pyplot.plot(list(bin_means.index), list(bin_means.left_school), 'o')

    plot_RDD_curve(df=pred, running_variable="dist_from_cut",
                   outcome="prediction", cutoff=0)
    plt.pyplot.title("Left university voluntarily")


def plot_nextCGPA(data, pred):
    plt.pyplot.figure(figsize=(8, 5))
    plt.pyplot.xlim(-1.5, 1.5, 0.1)
    plt.pyplot.ylim(-1, 1.5, 0.1)
    plt.pyplot.axvline(x=0, color='r')
    plt.pyplot.xlabel('First year GPA minus probation cutoff')
    plt.pyplot.ylabel('Subsequent CGPA minus cutoff')
    plt.pyplot.plot(data.nextCGPA.groupby(
        data['dist_from_cut_med10']).mean(), 'o')
    plot_RDD_curve(df=pred, running_variable="dist_from_cut",
                   outcome="prediction", cutoff=0)
    plt.pyplot.title("CGPA in the next enrolled term")
