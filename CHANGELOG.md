# Changelog

## Version 1.1.0 - 2024-05-14

### Change pollination-index
Pollination value can now be 0.5, as well as 0 and 1.


### Change how land use networks are constructed

No longer randomly assigned to farmers.  Now, a network is all farmers with the same attitude and initial land use, except those with land use 1,2,5,8 who have no network.

### Bug fix industry-rule and government-rule

Now will only alter land use of farms with specified current land use.

### Change industry-rule and government-rule

The effects of these rules now takes place after any incentivised choice and over rides these.
These rules are now controlled by sliders affecting the percentage of patches affected, rather than toggles.

### Redefine contiguity index

Now it is the mean size of contiguous land use clusters (no diagonal
connections). Also added world plot options to show clustering.

### Made decision-interval land use dependent

Introduced new variables landuse-decision-interval-minimum and
landuse-decision-interval-maximum and made decision-interval a
patch-owned variable that is randomly selected between these two.

### Modify how choices are made
A farmer's land use choice is now the land use with maximum weight, with random selection in case of a tie.

### Change base line rule
Remove rules applying to the business-as-usual behaviour class.

### Change some details of the neighbour rule

### Set the current land use to a decision weight of 1.
### Change how rules are controlled
Converted toggle controls to weight sliders.

### Implement year-of-first-product and year-of-last-product
To compute value

### Changed yield / value parameters

Removed livestock-yield and crop-yield and replaced with product-yield
and product-value


## Version 1.0.1 - 2024-05-03

### Fix random land use generation

Generate random initial land use with values closely matching the requested weights.
Previously the mean of the generated land use was correct but with significant variance.

## Version 1.0.0 - 2024-04-19

First version used for research purposes.

 
