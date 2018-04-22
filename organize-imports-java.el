;;; organize-impots-java.el --- a simple package                     -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Shen, Jen-Chieh
;; Created date 2018-04-16 13:12:01

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; Keywords: organize, java, imports, handy
;; Version: 0.0.1
;; URL: https://github.com/jcs090218/organize-imports-java
;; Compatibility: GNU Emacs 22.3 23.x 24.x later
;;
;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;
;; Organize Imports Java is an organize imports functionalities
;; plugins for editing Java code.  The only purpose of this
;; project is to implement the functionalities of how eclipse
;; treated as C-S-o key.  This plugin only uses elisp without
;; using any other plugin, so it make this plugin more portable
;; and light weight.
;;
;; (@* "TODO" )
;; * Performance is terrible when loading all the jar files to path.
;;   Hopefully I can find out a way to get around this issue.
;; * Performance imporvement when do imports task.
;;

;;; Code:

(defvar organize-imports-java-java-sdk-path "C:/Program Files/Java/jdk1.8.0_131"
  "Java SDK Path.")

(defvar organize-imports-java-inc-keyword "::SDK_PATH::"
  "Java SDK Path.")

(defvar organize-imports-java-lib-inc-file "oij.ini"
  "Java library include config file.")

(defvar organize-imports-java-path-config-file "paths-config.oij"
  "File generate store all the Java paths.")

(defvar organize-imports-java-vc-list '(".bzr"
                                        ".cvs"
                                        ".git"
                                        ".hg"
                                        ".svn")
  "Version Control list.")

(defvar organize-imports-java-path-buffer '()
  "All the available java paths store here.")

(defvar organize-imports-java-serach-regexp "[a-zA-Z0-9/_-]*/[a-zA-Z0-9_-]*.class"
  "Regular Expression to search for java path.")

(defvar organize-imports-java-unsearch-class-type '("[Bb]oolean"
                                                    "Double"
                                                    "Float"
                                                    "Integer"
                                                    "Long"
                                                    "[Ss]tring"
                                                    "Short"
                                                    "[Vv]oid")
  "Class types that do not need to imports any library path.")

(defvar organize-imports-java-non-src-list '("document"
                                             "internal"
                                             "sun")
  "List of non Java source keywords.")

(defvar organize-imports-java-font-lock-type-face "font-lock-type-face"
  "Type face that Jave applied to use.")


(defun organize-imports-java-is-contain-list-string (inList inStr)
  "Check if a string contain in any string in the string list.
INLIST : list of string use to check if INSTR in contain one of
the string.
INSTR : string using to check if is contain one of the INLIST."
  (let ((tmp-found nil))
    (dolist (tmpStr inList)
      (when (organize-imports-java-contain-string tmpStr inStr)
        (setq tmp-found t)))
    (equal tmp-found t)))

;;;###autoload
(defun organize-imports-java-keep-one-line-between ()
  "Keep one line between the two line of code.
If you want to keep more than one line use
`organize-imports-java-keep-n-line-between' instead."
  (interactive)
  (if (current-line-empty-p)
      (progn
        (jcs-next-line)

        ;; Kill empty line until there is one line.
        (while (current-line-empty-p)
          (jcs-kill-whole-line)))
    (progn
      ;; Make sure have one empty line between.
      (insert "\n"))))

(defun organize-imports-java-get-string-from-file (filePath)
  "Return filePath's file content.
FILEPATH : file path."
  (with-temp-buffer
    (insert-file-contents filePath)
    (buffer-string)))

(defun organize-imports-java-get-current-dir ()
  "Return the string of current directory."
  default-directory)

(defun organize-imports-java-file-directory-exists-p (filePath)
  "Return `True' if the directory/file exists.
Return `False' if the directory/file not exists.

FILEPATH : directory/file path.

NOTE(jenchieh): Weird this only works for directory not for
the file."
  (equal (file-directory-p filePath) t))

(defun organize-imports-java-is-vc-dir-p (dirPath)
  "Return `True' is version control diectory.
Return `False' not a version control directory.
DIRPATH : directory path."

  (let ((tmp-is-vc-dir nil))
    (dolist (tmp-vc-type organize-imports-java-vc-list)
      (let ((tmp-check-dir (concat dirPath "/" tmp-vc-type)))
        (when (organize-imports-java-file-directory-exists-p tmp-check-dir)
          (setq tmp-is-vc-dir t))))
    ;; Return retult.
    (equal tmp-is-vc-dir t)))

(defun organize-imports-java-up-one-dir-string (dirPath)
  "Go up one directory and return it directory string.
DIRPATH : directory path."
  ;; Remove the last directory in the path.
  (string-match "\\(.*\\)/" dirPath)
  (match-string 1 dirPath))

(defun organize-imports-java-vc-root-dir ()
  "Return version control root directory."
  (let ((tmp-current-dir (organize-imports-java-get-current-dir))
        (tmp-result-dir ""))
    (while (organize-imports-java-contain-string "/" tmp-current-dir)
      (when (organize-imports-java-is-vc-dir-p tmp-current-dir)
        ;; Return the result, which is the version control path
        ;; or failed to find the version control path.
        (setq tmp-result-dir tmp-current-dir))
      ;; go up one directory.
      (setq tmp-current-dir (organize-imports-java-up-one-dir-string tmp-current-dir)))
    ;; NOTE(jenchieh): if you do not like `/' at the end remove
    ;; concat slash function.
    (concat tmp-result-dir "/")))

(defun organize-imports-java-contain-string (in-sub-str in-str)
  "Check if a string is a substring of another string.
Return true if contain, else return false.
IN-SUB-STR : substring to see if contain in the IN-STR.
IN-STR : string to check by the IN-SUB-STR."
  (string-match-p (regexp-quote in-sub-str) in-str))

(defun organize-imports-java-parse-ini (filePath)
  "Parse a .ini file.
FILEPATH : .ini file to parse."

  (let ((tmp-ini (get-string-from-file filePath))
        (tmp-ini-list '())
        (tmp-pair-list nil)
        (tmp-keyword "")
        (tmp-value "")
        (count 0))
    (setq tmp-ini (split-string tmp-ini "\n"))

    (dolist (tmp-line tmp-ini)
      ;; check not comment.
      (when (not (string-match-p "#" tmp-line))
        ;; Split it.
        (setq tmp-pair-list (split-string tmp-line "="))

        ;; Assign to temporary variables.
        (setq tmp-keyword (nth 0 tmp-pair-list))
        (setq tmp-value (nth 1 tmp-pair-list))

        ;; Check empty value.
        (when (and (not (string= tmp-keyword ""))
                   (not (equal tmp-value nil)))
          (let ((tmp-list '()))
            (push tmp-keyword tmp-list)
            (setq tmp-ini-list (append tmp-ini-list tmp-list)))
          (let ((tmp-list '()))
            (push tmp-value tmp-list)
            (setq tmp-ini-list (append tmp-ini-list tmp-list)))))
      (setq count (1+ count)))

    ;; return list.
    tmp-ini-list))

(defun organize-imports-java-get-properties (ini-list in-key)
  "Get properties data.  Search by key and return value.
INI-LIST : ini list.  Please use this with/after using
`organize-imports-java-parse-ini' function.
IN-KEY : key to search for value."
  (let ((tmp-index 0)
        (tmp-key "")
        (tmp-value "")
        (returns-value ""))

    (while (< tmp-index (length ini-list))
      ;; Get the key and data value.
      (setq tmp-key (nth tmp-index ini-list))
      (setq tmp-value (nth (1+ tmp-index) ini-list))

      ;; Find the match.
      (when (string= tmp-key in-key)
        ;; return data value.
        (setq returns-value tmp-value))

      ;; Search for next key word.
      (setq tmp-index (+ tmp-index 2)))

    ;; Found nothing, return empty string.
    returns-value))

(defun organize-imports-java-is-in-list-string (inList str)
  "Check if a string in the string list.
INLIST : list of strings.
STR : string to check if is inside the list of strings above."
  (let ((in-list nil))
    (dolist (tmp-str inList)
      (when (string-match tmp-str str)
        (setq in-list t)))
    (equal in-list t)))

(defun organize-imports-java-re-seq (regexp string)
  "Get a list of all regexp match in a string.

REGEXP : regular expression.
STRING : string to do searching."
  (save-match-data
    (let ((pos 0)
          matches)
      (while (string-match regexp string pos)
        (push (match-string 0 string) matches)
        (setq pos (match-end 0)))
      matches)))

(defun organize-imports-java-strip-duplicates (list)
  "Remove duplicate value from list.
LIST : list you want to remove duplicates."
  (let ((new-list nil))
    (while list
      (when (and (car list) (not (member (car list) new-list)))
        (setq new-list (cons (car list) new-list)))
      (setq list (cdr list)))
    (nreverse new-list)))

(defun organize-imports-java-flatten (l)
  "Flatten the multiple dimensional array to one dimensonal array.
'(1 2 3 4 (5 6 7 8)) => '(1 2 3 4 5 6 7 8).

L : list."
  (cond ((null l) nil)
        ((atom l) (list l))
        (t (loop for a in l appending (organize-imports-java-flatten a)))))

(defun organize-imports-java-unzip-lib ()
  "Decode it `.jar' binary to readable data strucutre."

  ;; Reset list.
  (setq organize-imports-java-path-buffer '())

  (let ((tmp-lib-inc-file (concat
                           (organize-imports-java-vc-root-dir)
                           organize-imports-java-lib-inc-file))
        (tmp-lib-list '())
        ;; Key read from the .ini/.properties file.
        ;;(tmp-lib-key "")
        ;; Value read from the .ini/.properties file.
        (tmp-lib-path "")
        ;; Buffer read depends on one of the `tmp-lib-path'.
        (tmp-lib-buffer nil)
        ;; After search using regular expression and add all the
        ;; paths to the list/array.
        (tmp-class-list '())
        ;; index through the lib/jar paths list.
        (tmp-index 0)
        ;; length of the lib/jar paths list.
        (tmp-lib-list-length -1)
        ;; First character of the path readed from .ini file.
        (tmp-first-char-from-path nil))
    (when (file-exists-p tmp-lib-inc-file)
      ;; Read the ini file, in order to get all the target
      ;; lib/jar files.
      (setq tmp-lib-list (organize-imports-java-parse-ini tmp-lib-inc-file))

      ;; Get the length of the library list
      (setq tmp-lib-list-length (length tmp-lib-list))

      (while (< tmp-index tmp-lib-list-length)
        ;; Get the key of the path.
        ;;(setq tmp-lib-key (nth tmp-index tmp-lib-list))
        ;; Get the value of the path.
        (setq tmp-lib-path (nth (1+ tmp-index) tmp-lib-list))

        ;; Get the first character of the path.
        (setq tmp-first-char-from-path (substring tmp-lib-path 0 1))

        (cond (;; If the first character is not '.', then we use
               ;; absolute path instead of version control relative path.
               (string= tmp-first-char-from-path ".")
               (progn
                 ;; Modefied path to version control path.
                 (setq tmp-lib-path (concat (organize-imports-java-vc-root-dir) tmp-lib-path))))
              ;; Swap #SDK_PATH# to valid Java SDK path, if contain.
              ((organize-imports-java-contain-string organize-imports-java-inc-keyword
                                                     tmp-lib-path)
               (progn
                 (setq tmp-lib-path (s-replace organize-imports-java-inc-keyword
                                               organize-imports-java-java-sdk-path
                                               tmp-lib-path)))))

        ;; Read the jar/lib to temporary buffer.
        (setq tmp-lib-buffer (organize-imports-java-get-string-from-file tmp-lib-path))

        ;; Get all the library path strings by using
        ;; regular expression.
        (setq tmp-class-list (organize-imports-java-re-seq
                              organize-imports-java-serach-regexp
                              tmp-lib-buffer))

        ;; Add the paths to the list.
        (push tmp-class-list organize-imports-java-path-buffer)

        ;; Add up index.
        (setq tmp-index (+ tmp-index 2))))))

(defun organize-imports-java-erase-config-file ()
  "Clean all the buffer in the config file."
  (write-region ""  ;; Start, insert nothing here in order to clean it.
                nil  ;; End
                ;; File name (concatenate full path)
                (concat (organize-imports-java-vc-root-dir) organize-imports-java-path-config-file)
                ;; Overwrite?
                nil))

;;;###autoload
(defun organize-imports-java-reload-paths ()
  "Reload the Java include paths once."
  (interactive)

  ;; Import all libs/jars.
  (organize-imports-java-unzip-lib)

  ;; Flatten it.
  (setq organize-imports-java-path-buffer
        (organize-imports-java-flatten organize-imports-java-path-buffer))

  ;; Remove duplicates value from list.
  (setq organize-imports-java-path-buffer
        (organize-imports-java-strip-duplicates organize-imports-java-path-buffer))

  ;; Erase buffer before inserting.
  (organize-imports-java-erase-config-file)

  (let ((tmp-first-char-from-path "")
        (tmp-write-to-file-content-buffer ""))

    ;; Write into file so we don't need to do it every times.
    (dolist (tmp-path organize-imports-java-path-buffer)
      ;; Get the first character of the path.
      (setq tmp-first-char-from-path (substring tmp-path 0 1))

      (when (and (not (equal (upcase tmp-first-char-from-path) tmp-first-char-from-path))
                 (not (organize-imports-java-is-contain-list-string organize-imports-java-non-src-list
                                                                    tmp-path))
                 (not (organize-imports-java-is-digit-string tmp-first-char-from-path))
                 (not (string= tmp-first-char-from-path "-"))
                 (not (string= tmp-first-char-from-path ".")))
        ;; Swap `/' to `.'.
        (setq tmp-path (s-replace "/" "." tmp-path))

        ;; Remove `.class'.
        (setq tmp-path (s-replace ".class" "" tmp-path))

        ;; Add line break at the end.
        (setq tmp-path (concat tmp-path "\n"))

        ;; add to file content buffer.
        (setq tmp-write-to-file-content-buffer (concat tmp-path tmp-write-to-file-content-buffer))))

    ;; Write to file all at once.
    (write-region tmp-write-to-file-content-buffer  ;; Start
                  nil  ;; End
                  ;; File name (concatenate full path)
                  (concat (organize-imports-java-vc-root-dir) organize-imports-java-path-config-file)
                  ;; Overwrite?
                  t)))

(defun organize-imports-java-get-current-point-face ()
  "Get current point's type face as string."
  (interactive)
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    face))

(defun organize-imports-java-current-point-face-p (faceName)
  "Is the current face name same as pass in string?
FACENAME : face name in string."
  (string= (jcs-get-current-point-face) faceName))

(defun organize-imports-java-get-type-face-keywords-by-face-name (faceName)
  "Get all the type keywords in current buffer.
FACENAME : face name to search."

  (let ((tmp-keyword-list '()))
    (save-excursion
      ;; Goto the end of the buffer.
      (goto-char (point-max))

      (while (< (point-min) (point))
        (backward-word)
        (when (organize-imports-java-current-point-face-p faceName)
          (push (thing-at-point 'word) tmp-keyword-list))))
    tmp-keyword-list))

(defun organize-imports-java-insert-import-lib (tmp-one-path)
  "Insert the import code line here.  Also design it here.
Argument TMP-ONE-PATH Temporary passing in path, use to insert import string/code."
  (insert "import ")
  (insert tmp-one-path)
  (insert ";\n"))

;;;###autoload
(defun organize-imports-java-kill-whole-line ()
  "Deletes a line, but does not put it in the `kill-ring'."
  (interactive)
  (if (use-region-p)
      (delete-region (region-beginning) (region-end))
    (progn
      (move-beginning-of-line 1)
      (kill-line 1)
      (setq kill-ring (cdr kill-ring)))))

;;;###autoload
(defun organize-imports-java-clear-all-imports ()
  "Clear all imports in the current buffer."
  (interactive)
  (save-excursion
    (goto-char (point-max))
    (while (< (point-min) (point))
      (beginning-of-line)
      (when (string= (thing-at-point 'word) "import")
        (organize-imports-java-kill-whole-line))
      (jcs-previous-line))))

(defun organize-imports-java-is-digit-string (c)
  "Check if C is a digit."
  (or (string= c "0")
      (string= c "1")
      (string= c "2")
      (string= c "3")
      (string= c "4")
      (string= c "5")
      (string= c "6")
      (string= c "7")
      (string= c "8")
      (string= c "9")))

;;;###autoload
(defun organize-imports-java-do-imports ()
  "Do the functionalitiies of how organize imports work."
  (interactive)

  ;; Clear all imports before insert new imports.
  (organize-imports-java-clear-all-imports)

  (save-excursion
    (let ((tmp-config-fullpath (concat (organize-imports-java-vc-root-dir) organize-imports-java-path-config-file)))
      ;; If the file does not exists, load the Java path once.
      ;; Get this plugin ready to use.
      (when (not (file-exists-p tmp-config-fullpath))
        (organize-imports-java-reload-paths))

      (let ((tmp-type-keyword-list (organize-imports-java-get-type-face-keywords-by-face-name
                                    organize-imports-java-font-lock-type-face))
            ;; Read file to buffer.
            (tmp-path-buffer (organize-imports-java-get-string-from-file tmp-config-fullpath))
            (tmp-path-list '())
            (tmp-one-path "")
            ;; Paths that are ready to insert.
            (tmp-pre-insert-path-list '()))

        ;; Make the path buffer back to list.
        ;;
        ;; Why I use the word 'back'? Because when we make our
        ;; list, we made it from one chunk of buffer/string.
        ;; And now we split the string back to list again.
        (setq tmp-path-list (split-string tmp-path-buffer "\n"))

        (dolist (tmp-type-class-keyword tmp-type-keyword-list)
          (dolist (tmp-path tmp-path-list)
            (when (not (organize-imports-java-is-in-list-string organize-imports-java-unsearch-class-type
                                                                tmp-type-class-keyword))
              (let ((tmp-split-path-list '())
                    (tmp-last-element ""))

                ;; split the string into list
                (setq tmp-split-path-list (split-string tmp-path "\\."))

                ;; the last element is always the class name.
                (setq tmp-last-element (nth (1- (length tmp-split-path-list)) tmp-split-path-list))

                ;; Check the last class name is the same.
                (when (string= tmp-type-class-keyword tmp-last-element)
                  (setq tmp-one-path tmp-path)

                  ;; add the path to pre-insert list.
                  (push tmp-one-path tmp-pre-insert-path-list))))))

        ;; Sort in alphabetic order.
        (setq tmp-pre-insert-path-list (sort tmp-pre-insert-path-list 'string<))

        ;; Check package keyword exists.
        (goto-char (point-min))

        ;; Make it under `package' line.
        (when (string= (thing-at-point 'word) "package")
          (end-of-line)
          (insert "\n"))

        ;; Insert all import path line.
        (let ((tmp-split-path-list '())
              (tmp-first-element "")
              (tmp-record-first-element ""))
          (dolist (tmp-in-path tmp-pre-insert-path-list)

            ;; split the path into list by using `.' delimiter.
            (setq tmp-split-path-list (split-string tmp-in-path "\\."))

            ;; the first element is always the class name.
            (setq tmp-first-element (nth 0 tmp-split-path-list))

            (when (not (string= tmp-first-element tmp-record-first-element))
              (insert "\n")

              ;; record it down.
              (setq tmp-record-first-element tmp-first-element))

            (organize-imports-java-insert-import-lib tmp-in-path)))

        ;; keep one line.
        (organize-imports-java-keep-one-line-between)))))


(provide 'organize-imports-java)
;;; organize-imports-java.el ends here
