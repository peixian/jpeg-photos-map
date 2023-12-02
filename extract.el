(defun format-gps-coordinates (latitude longitude)
  "Format latitude and longitude into a human-readable string."
  (let ((lat-hem (if (string-match "S" latitude) "S" "N"))
        (long-hem (if (string-match "W" longitude) "W" "E")))
    (format "%s, %s"
            (replace-regexp-in-string " deg.*" "" latitude)
            (replace-regexp-in-string " deg.*" "" longitude))))

(defun extract-exif-geolocation (file)
  "Extract and format the EXIF geolocation data from an image file."
  (let ((exif-output (shell-command-to-string (format "exiftool -gpslatitude -gpslongitude -n -T %s" (shell-quote-argument file)))))
    (if (string-match "\\([-+]?[0-9.]+\\)[ \t]+\\([-+]?[0-9.]+\\)" exif-output)
        (let ((latitude (match-string 1 exif-output))
              (longitude (match-string 2 exif-output)))
          (format-gps-coordinates latitude longitude))
      "No geolocation data")))

(defun extract-exif-date (file)
  "Extract the EXIF date data from an image file."
  (let ((exif-date-output (shell-command-to-string (format "exiftool -DateTimeOriginal -T %s" (shell-quote-argument file)))))
    (if (string-match "\\([0-9:\\-]+\\) \\([0-9:]+\\)" exif-date-output)
        (match-string 0 exif-date-output)
      "No date data")))

  (defun generate-org-gallery-with-exif-and-csv ()
  "Generate an Org mode gallery file with EXIF geolocation data and a separate CSV file with image details."
  (interactive)
  (let ((image-dir "~/code/writing/assets/shrines")
        (org-file "~/code/writing/blog/shrines.org")
        (csv-file "~/code/writing/assets/shrines/locations.csv"))
    (with-temp-file org-file
      (insert "#+TITLE: Shrines\n")
      (insert "#+AUTHOR: Peixian\n")
      (insert "#+DATE: 2023-11-26\n")
      (insert "#+URI: /shrines/\n")
      (insert "#+TAGS: :projects\n\n")
      (insert "* Locations:\n\n[[file:../assets/shrines/map.svg]]\n\n")
      (insert "Photographs of various shrines I've seen. A shrine here is basically anything I consider to have spiritual significance.\n\n"))
    (with-temp-file csv-file
      (insert "Name,Date,Longitude,Latitude\n") ; CSV header
      (dolist (file (directory-files image-dir t "\\(jpg\\|jpeg\\|png\\|JPG\\|gif\\)$"))
        (unless (or (string-equal (file-name-nondirectory file) ".")
                    (string-equal (file-name-nondirectory file) ".."))
          (let* ((exif-data (extract-exif-geolocation file))
                 (exif-date (extract-exif-date file))
                 (file-name (file-name-nondirectory file)))
            (with-temp-buffer
              (insert (format "[[file:../assets/shrines/%s]]\n" (file-relative-name file image-dir)))
              (insert (format "< %s > - " exif-date))
              (insert (format "< /%s/ >\n\n" exif-data))
              (append-to-file (point-min) (point-max) org-file))
            (insert (format "%s,%s,%s\n" file-name exif-date exif-data))))))))
