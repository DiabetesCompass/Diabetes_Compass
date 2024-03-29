# Purpose
We type 1 diabetics struggle daily with the decisions we must make to manage our blood glucose (BG).  
What to eat or drink, when and how much insulin to take to compensate for the food we ingest, how much residual effect is there from previous insulin doses or food eaten, when should we test our BG?  
These are some of the decisions we face and what we decide can effect our health for years to come.  
Wouldn't it be nice if there was an app for our mobile phone that made this process easier and allowed us to look back at previous days to see how our past decisions worked out so that we could use those results to help us make better decisions in the future?  
This BG Compass app provides an evolving tool for use by type 1 (and, perhaps, type 2) diabetics to visualize the effects of the choices made daily in managing their disease.The goal is to make the plots of estimated BG, trends, and estimated HA1c as accurate as is possible using the information that is typically used for this and is readily available.  
The two major contributors to the curves of estimated blood glucose (BG) are, of course, food and insulin.  
This app provides a simple means of accessing food nutritional content (carbohydrate) data by extracting that data from internet databases or from historical data previously input by the user.  
The user is able to select the type of fast acting insulin used to compensate for food or drink consumed and the app plots a typical estimated BG dose response for the dose selected using the patients own insulin sensitivity, adjusted for the timing of that dose.  
Likewise, the app computes a typical dose response curve from the food that is selected or input by the user, including the timing of that food, and combines that food dose response with the insulin dose response.  
Thus, the app computes a composite curve that includes all those variables and their timing.  
This response is first displayed as a tentative curve allowing the user to make adjustments in the timing or dosing of any variable and visualizing how those changes might effect the overall curve.  
This, therefore allows a user to modify and adjust management and planning as seen fit to optimize results.  
Measured BG data is also input to the app to make further adjustments as time goes by since estimates are seldom exactly correct.  
This app allows the user to choose adjustment doses more carefully and efficiently rather than just guessing.  
The app also includes code for estimating hemoglobin A1c (HA1c) to further help users tune their diet and insulin dosing by visualizing trend curves of estimated HA1c on a daily basis.  This can be useful in longer term management.
All recorded data entries can be recalled and used for later adjustments or to use for recuring items.  
For example, if a person tends to eat the same thing for breakfast often, the nutritional content of that item can be gradually adjusted and saved in memory (as a favorite) for future use.  
This makes such future estimates more accurate as they are tuned to the individual.  
Of course, any such estimates can be somewhat different from previous ones due to the many other variables that enter into BG levels.  
Trend data and plots are available to review progress in tuning our management of BG levels.  
These plots extend back in time as far as the recorded data exists and can be helpful in improving management.  

# Info for Developers

## Objective C and Swift
Initially the app was written in Objective C. Some newer code uses Swift.  
The app may use a bridging header such as BGCompass-Bridging-Header.h to expose Objective C to Swift.  
Swift extensions to Objective C classes may not need or allow annotation @objc.  
For example the app may use an extension such as TrendsAlgorithmModelExtension.swift.  
http://ctarda.com/2016/05/swift-extensions-can-be-applied-to-objective-c-types/  

## Core Data / Magical Record
The app uses Core Data and Magical Record. Most of this is done in Objective C.  
The current developers have not figured out how to share the database context between Objective C and Swift.  
Objective C writes to Core Data. It may provide helper methods to supply managed objects to Swift.  

# References
https://en.wikipedia.org/wiki/Glycated_hemoglobin

