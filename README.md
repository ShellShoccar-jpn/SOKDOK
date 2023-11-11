# SOKDOK

SOKDOK (速読) means speed-readning. This gives you the feelings of speed-readers.

## How to Try

Before trying, run the set-up script.

```
$ ./00setup.sh
```

Then, try reading by the viewer, like this.

```
$ ./viewers/center.sh 2000 sampletexts/sfnovel_intro2.ja.txt
```
The above first argument "2000" means the speed of 2000 letters per minute. It is a speed for speed-readers.

## List of Files

```
./ --+-- README.md                          This file
     |                                      
     +-- 00setup.sh                         Setup script (Run this 1st!)
     |                                     
     +-- viewers/                           SOKDOK Viewers Directory
     |   |                                  
     |   `---------- center.sh              Center version
     |                                      
     +-- lib/                               Library Directory for the Viewers
     |   |                                  
     |   +---------- utf8wc                 UTF-8 Text Length Counting Command
     |   |                                  
     |   +---------- c_src/                 C Program File Directory
     |               |                      
     |               +---------- ptw        Pseudo Terminal Wrapper Command
     |               `---------- tscat      Timestamp oriented Cat Commdna
     |                                      
     `-- sampletexts/                       Sample Text Directory
         |                                  
         +---------- sfnovel_intro1.ja.txt  A SF novel (one-clause, in Japanese)
         +---------- sfnovel_intro2.ja.txt  A SF novel (short clause bunch, in Japanese)
         `---------- sfnovel_intro3.ja.txt  A SF novel (log clause bunch, in Japanese)
```
