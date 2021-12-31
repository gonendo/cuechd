# cuechd
This small utility allows you to compress multiple .cue files to .chd recursively with a given directory path.

### Features
- Recursively compress all .cue files in a given directory to .chd
- Automatically delete .cue and its .bin files after successful compression
- Can automatically generate a .m3u file for multi-discs games (useful for disk control in retroarch). It will only work if a pattern from patterns.txt is found (see Usage section below for more info)

### Requirements
This needs **chdman** to be installed. You can get it from the **mame-tools** package in your distribution.

### Usage

```
./cuechd.sh [PATH]
```
ex:
```
./cuechd.sh ./isos
```

#### Generating the m3u file

**_cuechd_** will **only** generate the m3u file if a pattern is found in the .cue name. These patterns can be found in the **patterns.txt** file.

Default patterns are :
```
_cd[0-9] > matches "game_cd1.cue"
 \(Disc [0-9]\) > matches "game (Disc 1).cue"
```
Feel free to add more if necessary (use regex syntax)

##### Full ex:
given this configuration:
```
./isos/xenogears/xenogears_cd1_undub.cue
./isos/xenogears/xenogears_cd1_undub.bin
./isos/xenogears/xenogears_cd2_undub.cue
./isos/xenogears/xenogears_cd2_undub.bin
```
**_cuechd_** will generate 3 files:
```
./isos/xenogears/xenogears_cd1_undub.chd
./isos/xenogears/xenogears_cd2_undub.chd
./isos/xenogears/xenogears_undub.m3u
```
the m3u file was generated since the pattern _cd[0-9] was found

xenogears_undub.m3u will look like this:
```
xenogears_cd1_undub.chd
xenogears_cd2_undub.chd
```

