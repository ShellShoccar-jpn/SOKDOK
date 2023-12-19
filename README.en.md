# SOKDOK

SOKDOK (速読) means speed-readning. This gives you the feelings of speed-readers.

（日本語版は[こちら](README.ja.md)）

## How to Try

Before trying, run the set-up script.

```
$ ./00setup.sh
```

Then, try reading with the viewer, like this.

```
$ ./viewers/center.sh 2000 sampletexts/sfnovel_intro2.ja.txt
```
The above first argument "2000" means the speed of 2000 letters per minute. It is a speed for speed-readers.

Next, try the "serial" and "elusive" reader, like this.

```
$ ./viewers/serial.sh 2000 sampletexts/sfnovel_intro2.ja.txt
$ ./viewers/elusive.sh 2000 sampletexts/sfnovel_intro2.ja.txt
```

Were you able to read that smoothly? I know you couldn't. That is because you must move your eyeballs violently while reading, particularly while using the elusive reader. That's a very stressful work, **like reading a spaghetti code**.

What I want to say with there viewers are

> Be conscious of avoiding eye-moving as well as possible while making others read your program.

You probably think it is helpful for programmers to use branching syntax (`if`, `switch`, `case`, `goto`), looping syntax (`for`, `while`), and subroutines. But using them too much makes your program dirty or stressful for others to read because these mechanisms increase eye-moving while reading a program.

## BONUS: Abacus Examination

I give you a bonus program, "abacus.sh," too. It is to test you on an abacus examination known as "Flash Anzan" in Japan. It is a kind of mental arithmetic. After starting this program, you can see a lot of numbers on the screen, replaced one after another in a very short time. You have to answer the sum of their numbers.

To try this, type this command.

```
$ ./bonus/abacus.sh 1kyu
```

"1kyu" is one of the grades (difficulty) on the Flash Anzan. The grades this program supports are the following. They are ordered from the easiest to the most difficult. "10kyu," "9kyu," "8kyu," ..., "2kyu," "1kyu," and "1dan," "2dan," ..., "19dan," "20dan."


## List of Files

```
./ --+-- README.md                          "Readme" file (This file)
     +-- README.en.md                       "Readme" file (This file)
     +-- README.ja.md                       "Readme" file (Japanese version)
     |                                      
     +-- 00setup.sh                         Setup script (Run this 1st!)
     |                                      
     +-- viewers/                           SOKDOK Viewers Directory
     |   |                                  
     |   +---------- center.sh              Center version (Easist to read)
     |   |                                  
     |   +---------- serial.sh              Serial version (Equal to reading ordinary documents)
     |   |                                  
     |   `---------- elusive.sh             Elusive version (Hardest to read)
     |                                      
     +-- lib/                               Library Directory for the Viewers
     |   |                                  
     |   +---------- utf8wc                 UTF-8 Text Length Counting Command
     |   |                                  
     |   +---------- c_src/                 C Program File Directory
     |               |                      
     |               +---------- MAKE.sh    Script to compile the following two programs
     |               +---------- ptw        Pseudo Terminal Wrapper Command
     |               `---------- tscat      Timestamp oriented Cat Commdna
     |                                      
     +-- sampletexts/                       Sample Text Directory
     |   |                                  
     |   +---------- sfnovel_intro1.ja.txt  A SF novel (one-clause, in Japanese)
     |   +---------- sfnovel_intro2.ja.txt  A SF novel (short clause bunch, in Japanese)
     |   `---------- sfnovel_intro3.ja.txt  A SF novel (log clause bunch, in Japanese)
     |
     `-- bonus/                             Bonus programs
         |
         `---------- abacus.sh              Abacus Examiner (known as "Flash Anzan" in Japan)
```
