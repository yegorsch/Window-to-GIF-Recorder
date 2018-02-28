#Window-To-Gif Recorder 
I have been using LICECap program for desktop GIF recordording for a while now. Unfortunately, in LICECap you have to adjust recording for every window separately and sometimes it does not work so well. I decided to make use of Apple Quartz Window Services API and imporve the concept a little bit. Now you can select the specific window you want to record and adjust the image/scale quality and FPS.

Update (28.02.17):
The app needs much refactoring and memory optimization but it does work. Be carefull with high-quality GIF settings - working with those huge bitmaps is quite costly in CoreImage. Hopefully I will find time to fix it!
