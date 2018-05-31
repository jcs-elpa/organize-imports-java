# organize-imports-java #

Organize Imports Java is an organize imports functionality plugin for
editing Java code. This plugin mimics Eclipse uses of the C-S-o key.
And it only uses elisp, making it more portable and light weight.
<br/><br/>


## How to use? ##
1. Create an oij.ini file at the version control root directory.
An example can be found below in the “INI Example” section.
2. After you have included all the Java Libraries into the oij.ini
file. You can run `organize-imports-java-do-imports` and it will load
the included jar path in the oij.ini file and import in the current
buffer (It will take a while loading all the jar/lib files the first
time to create the cache file). If you wish to refresh the
paths-config.oij file then just call `organize-imports-java-reload-paths`
function, and it will do the work.


## INI Example ##
This is an example of oij.ini file. It Includes all the java
library paths. This plugin can search for all the paths inside
this jars files you include in this file.
```
#
# Include Java .jar file paths.
#

# Use JavaSE-1.7 Environment.
rt=::SDK_PATH::/jre/lib/rt.jar

# External Libraries
JCSQtJ-1.0.2=./test_lib/JCSQtJ-1.0.2.jar
qtjambi-4.8.7=./test_lib/qtjambi-4.8.7.jar

```


## Configuration ##
Setup Java JDK.
```
(setq organize-imports-java-java-sdk-path "/path/to/java/jdk/")
```

Include all your library path in the file. Should place
this file at the root of version control directory.
```
(setq organize-imports-java-lib-inc-file "oij.ini")
```

After reading all the library path, this file will be generated
for cache search on what library should be import to current
buffer/file.
```
(setq organize-impots-java-path-config-file "paths-config.oij")
```

This plugin detect each word's font face in the current buffer to find
which word is the class keyword to import. By setting this variable
can add/remove the list of font face you want this plugin to detect
the class type.
```
(setq organize-imports-java-font-lock-type-face '("font-lock-type-face"))
```

## Key Bindings ##
If you want, you can just bind the key to the function directly.
```
;; Do the import, if could not find paths-config.oij file then it will
;; reload the paths once.
(define-key java-mode-map (kbd "C-S-o") #'organize-imports-java-do-imports)

;; You can either delete paths-config.oij file at the version control root
;; directory or just call this function. Both will trigger the reloading
;; path functionality.
(define-key java-mode-map (kbd "C-S-o") #'organize-imports-java-reload-paths)
```


## Comparison ##
Emacs using this package                                                           | Eclipse built-in
:---------------------------------------------------------------------------------:|:----------------------------------------------------------------------------------:|
<img src="./screenshot/orangize_imports_java_demo1.gif" width="450" height="457"/> | <img src="./screenshot/organize-imports-in-eclipse.gif" width="450" height="457"/> |


## Some Possible Improvement ##
* Performance is terrible when loading all the jar files to path.
Hopefully I can find out a way to get around this issue.


## Contribution ##
If you would like to contribute to this project. You may either
clone and make pull request to this repository. Or you can
clone the project and make your own branch of this tool. Any
methods are welcome!
