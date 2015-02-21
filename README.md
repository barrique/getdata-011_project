## Readme

The process of tidying the dataset was carried on as follows:

1. The available documentation was analyzed, with the aim of understanding the role of each file and the number of features/variables encoded in them.
2. The files were read into the R environment.
3. *X_train* and *X_test* rows were combined in a single data frame.
4. *subject_train* and *subject_test* rows were combined in a single data frame.
5. *y_train* and *y_test* rows were combined in a single data frame of labels.
6. A new data frame was created associating to each value in the data frame 5. the activity names in *activity_labels*.
7. The data frame from point 3. was filtered by the regular expression *(mean|std)\\(\\)* to only keep the columns related to mean and standard deviation.
8. The data frames from points 5. 6. 7. were joined in a single data frame by column.
9. The data frame from 8. is grouped by subject and activity, and a new data frame containing the mean of each column for each subject,activity pair is computed.
10. The data frame from 9. is written to file.
11. The codebook is automatically generated and written to file.