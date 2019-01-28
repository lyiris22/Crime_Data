# Milestone 3

### Reflection on the usefulness of the feedback you received

The feedback session was very insightful and helpful in updating our app to be more user
friendly. Before going into the feedback session we knew there were some bugs
with our app but it was interesting to have people find new issues. We were able
to use the feedback session to improve our app visually and functionally.

##### General Feedback
The feedback for our app was very positive. People generally found our app intuitive
and easy to use.


##### Map Tab
With the Map tab a consistent piece of feedback we received was that having
the city dropdown widget present when it didn't change the map was confusing. This was a known
issue before the feedback session and therefore it was not surprising that users found it frustrating.
Another piece of feedback that we received from several reviewers was that the year slider widget looked like a range selector (as opposed to a single-value selector)
which was something we did not expect users to say. A few users suggested changing the style of our crime rate circles on the map. Other pieces of consistent feedback we received were that we should provide more info about each city by adding more detail to the tooltip, and we should add a scale to the circle size. We also realized that users didn't know that they could click on the circles to bring up the tooltip and see the name of the city.

##### Single City
For the Single City tab the main piece of feedback was about removing the widgets that didn't change anything on that tab.
We received complaints about our plot not displaying when the user first clicked on the tab. Several of our reviewers also commented on being confused about what the bars on the plot were displaying.



### Reflection on how your project has changed since Milestone 2, and why

Our app has become more functional and visually appealing since Milestone 2. We felt the feedback was very helpful in shaping our app to be more user-friendly.
We added a Help tab to contain information about the dataset and to provide simple instructions on how to use the app.

We removed the widgets on each tab that didn't function, which meant removing the
'select a city' widget from the Map tab. We tried to change the style of the year slider (since in our feedback session several reviewers thought it was displaying a range), but unfortunately we couldn't change the slider because of how it is implemented by Shiny. We updated the Map tab so that when a user hovers over a city it display the values for that city's crime rates (as well as the city name and population). We think this is much more intuitive then making users click the individual circles to bring up the tooltip. We also changed the style of the circles on the map, making them more transparent so you can see overlapping data better. Finally, a big change that we implemented in the Map tab was changing the crime rates filter from a dropdown menu to a checkbox. Now a user can select several crimes rates at once and the circles will grow based on the selected rates. 

On the Single City tab we removed the year slider widget (which didn't do anything) and changed the crime type filter from a dropdown widget to check-box widget to make the plot more interactive. During the feedback session we received lots of feedback about placing population on a separate plot, but we ultimately decided not do this because we wanted population and the crime rates together so that the user
can easily see if the crime rates are changing due to changes in the population. However, in order to make it more clear that the bar graph is the population over time, we gave the user the ability to select whether or not to show the population and, if they do select it, those bars are interactively drawn on the plot. We believe that this will help to solve any confusion that users had. We were surprised we didn't receive more feedback on the table - in fact, people barely even noticed it. So, in this version, we changed its style and content to make it more noticeable. Finally, we improved the overall design aesthetic of our app by adding a theme and increasing the font sizes.
