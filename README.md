# CS663 course project: Video-Toonification
Inspired by [this paper](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/video_tooning.pdf) by Microsfot Research, we implemented an end-to-end automated video toonification algorithm with Mean Shift filtering in 6 dimensions: R, G, B, x, y and time.

We also implenented a simple Shot Detection algorithm to allow multiple scenes in a single video.

An example pair can be found here: [input]({{ site.url }}/assets/videos/cs663/combined_original.mp4)) and [output]({{ site.url }}/assets/videos/cs663/combined_meanshift.mp4)
