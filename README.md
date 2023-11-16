# Compression Algorithm Benchmark
Simple Shell script to benchmark different compression algorithms.

Just clone the repository or download the script, configure a couple of options at the top of the file, then run it.

The script will create a temporary folder to place temporary archives in, which will be deleted on exit.

The results will be written on a .csv file (filename configurable), and a summary will be printed when the tests end.

## Sample summary
```
Algorithm             Time(U+S)(s)  Time(E)(M:s)  ComprRatio  SpaceSave(%)
gzip                  92.63         1:28.72       1.32        24.60
bzip2                 240.72        3:55.97       1.37        27.22
zstd                  18.47         0:10.83       1.39        28.18
gzip (pigz)           141.63        0:09.55       1.32        24.57
bzip2 (lbzip2)        454.12        0:28.70       1.37        27.21
7z                    1358.48       2:21.49       1.47        32.35
rar                   1180.45       2:07.63       1.43        30.33
zip                   91.44         1:31.49       1.30        23.48
zstd -T0 -1           16.27         0:05.52       1.34        25.64
zstd -T0 -3 (def.)    20.67         0:05.55       1.39        28.18
zstd -T0 -5           156.39        0:20.59       1.41        29.15
zstd -T0 -10          290.06        0:37.86       1.43        30.40
zstd -T0 -15          568.39        1:16.71       1.44        30.68
zstd -T0 -19          1489.91       3:14.50       1.46        31.80
zstd -T0 --ultra -22  2268.53       5:29.36       1.53        34.91
```
