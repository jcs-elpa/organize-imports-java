# organize-imports-java #

Organize Imports Java is an organize imports functionalities plugins
for editing Java code. The only purpose of this project is to
implement the functionalities of how eclipse treated as C-S-o key.
This plugin only uses elisp without using any other plugin, so it
make this plugin more portable and light weight.
<br/><br/>


## How to use? ##
1. Create oij.ini file at the version control root directory.
The example can be find below INI Example section.
2. After you have include all the Java Libraries into oij.ini
file. You can just run `organize-imports-java-do-imports` and
it will load the included jar path in oij.ini file and do
the import in the current buffer. Just to let you know, it will
take a while lodaing all the jar/lib files the first time to
create the cache file.


## INI Example ##
This is an example of oij.ini file. Include all the java library
path so this plugin can search for all the paths inside this jars
files you include in this file.
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

## Key Bindings ##
```
;; If you want, you can just bind the key to the function directly.
(define-key java-mode-map (kbd "C-S-o") 'organize-imports-java-do-imports)
```


## Screen Shot ##
<img src="./screen_shot/orangize_imports_java_demo1.gif"/>


## Some Possible Improvement ##
* Performance is terrible when loading all the jar files to path.
Hopefully I can find out a way to get around this issue.
* Performance imporvement when do imports task.


## Contribution ##
If you would like to contribute to this project. You may either
clone and make pull request to this repository. Or you can
clone the project and make your own branch of this tool. Any
methods are welcome!
