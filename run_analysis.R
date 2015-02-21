library(data.table)
library(dplyr)
library(memisc)

# set working directory to source location and print it out
this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)
print(getwd())

read_data <- T

# known values
number.of.features <- 561
number.of.activities <- 6

# directories
dataset.dir <- "./UCI HAR Dataset/"
train.dir <- "./train/"
test.dir <- "./test/"

# common dataset files
activity.labels.f <- "./activity_labels.txt"
features.f <- "./features.txt"

# train and test files
y.train.f <- "./y_train.txt"
x.train.f <- "./X_train.txt"
subject.train.f <- "./subject_train.txt"

# train and test files
y.test.f <- "./y_test.txt"
x.test.f <- "./X_test.txt"
subject.test.f <- "./subject_test.txt"

if (read_data) {
    features <- fread(paste(dataset.dir,features.f,sep=""))
    setnames(features,colnames(features),c("index","name"))
    # check that they are 561 as per specification
    stopifnot(nrow(features) == number.of.features)
    
    # fread crashes while trying to read these two files
    x.train <- data.table(read.table(paste(dataset.dir,train.dir,x.train.f,sep=""), 
                                     stringsAsFactors=FALSE, colClasses=rep("numeric",number.of.features)))
    stopifnot(ncol(x.train) == number.of.features)
    number.obs.train <- nrow(x.train)
    x.test <- data.table(read.table(paste(dataset.dir,test.dir,x.test.f,sep=""), 
                                    stringsAsFactors=FALSE, colClasses=rep("numeric",number.of.features)))
    stopifnot(ncol(x.test) == number.of.features)
    number.obs.test <- nrow(x.test)
    
    subjects.train <- fread(paste(dataset.dir,train.dir,subject.train.f,sep=""))
    setnames(subjects.train,colnames(subjects.train),c("subject"))
    stopifnot(nrow(subjects.train) == number.obs.train)
    
    labels.train <- fread(paste(dataset.dir,train.dir,y.train.f,sep=""))
    setnames(labels.train,colnames(labels.train),c("label"))
    stopifnot(nrow(labels.train) == number.obs.train)
    
    subjects.test <- fread(paste(dataset.dir,test.dir,subject.test.f,sep=""))
    setnames(subjects.test,colnames(subjects.test),c("subject"))
    stopifnot(nrow(subjects.test) == number.obs.test)
    
    labels.test <- fread(paste(dataset.dir,test.dir,y.test.f,sep=""))
    setnames(labels.test,colnames(labels.test),c("label"))
    stopifnot(nrow(labels.test) == number.obs.test)
    
    activity.labels <- fread(paste(dataset.dir,activity.labels.f,sep=""))
    setnames(activity.labels,colnames(activity.labels),c("label","name"))
    stopifnot(nrow(activity.labels) == number.of.activities)
    
    closeAllConnections()  
}

# merge x train and test files
x.whole <- bind_rows(x.train,x.test)
setnames(x.whole, colnames(x.whole), features$name)

# merge subject train and test files
subjects.whole <- bind_rows(subjects.train,subjects.test)

# merge labels train and test files
labels.whole <- bind_rows(labels.train,labels.test)

# create a data fram with activitiy names in place of labels
activities.whole <- data.frame("activity" = factor(labels.whole$label, levels=activity.labels$label, 
                                                   labels = activity.labels$name))

# extract the columns related to mean and std from x whole
x.whole.meanstd <- x.whole[ , grepl("(mean|std)\\(\\)", colnames(x.whole))] # note the double \

# bind together the mean and std columns of x, subjects, and activities
data.whole.meanstd <- bind_cols(subjects.whole,activities.whole,x.whole.meanstd)

# compute the mean for each activity and each subject
d <- data.whole.meanstd %>% group_by(subject, activity) %>% summarise_each(funs(mean))

# this is the output tidy table!
write.table(d, "./output.txt", row.name=FALSE)

# and this is the machine-generated codebook
cb <- codebook(data.set(d))
capture.output(cb, file="codebook.txt")