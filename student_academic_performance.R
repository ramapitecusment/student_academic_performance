library(neuralnet)
library(caTools)
setwd("E:\\Desktop\\2\\GitProjects\\R\\DS-4 PRO")
edu = read.csv("student_academic_performance.csv")
str(edu)
summary(edu)
edu1 = edu

# FIXING data(scaling). Making it more interpretable for Neural network
edu$raisedhands <-(edu$raisedhands-min(edu$raisedhands)) /
  (max(edu$raisedhands)-min(edu$raisedhands))
edu$VisITedResources <-(edu$VisITedResources-min(edu$VisITedResources)) /
  (max(edu$VisITedResources)-min(edu$VisITedResources))
edu$AnnouncementsView <-(edu$AnnouncementsView-min(edu$AnnouncementsView)) /
  (max(edu$AnnouncementsView)-min(edu$AnnouncementsView))
edu$Discussion <-(edu$Discussion-min(edu$Discussion)) /
  (max(edu$Discussion)-min(edu$Discussion))
summary(edu)

# Making 1 and 0
edu$gender = 1*(edu$gender != "F")
edu$Relation = 1*(edu$Relation != "Father")
edu$ParentAnsweringSurvey = 1*(edu$ParentAnsweringSurvey != "No")
edu$ParentschoolSatisfaction = 1*(edu$ParentAnsweringSurvey != "Bad")
edu$StudentAbsenceDays = 1*(edu$StudentAbsenceDays != "Above-7")

# Adding additional argument in order to prevent deleting variables in Class
#levels(edu$Class) <- c(levels(edu$Class),"fake")
#edu$Class <- relevel(as.factor(edu$Class, ref = "fake"))

# Creating dummy variables for each class
sub = model.matrix(~ Class + gender + raisedhands + VisITedResources + AnnouncementsView
                   + Discussion + ParentAnsweringSurvey + ParentschoolSatisfaction + StudentAbsenceDays, 
                   data = edu)

colnames(sub)[1:3] <- c("ClassH","ClassL","ClassM")

set.seed(129)
split = sample.split(edu$Class, SplitRatio = 0.75)
Test = subset(sub, split == FALSE)
Train = subset(sub, split == TRUE)

# Cheking hiddens. The best hidden is 2
bucket_result = numeric()
x_bucket = numeric()
i = 0
while (i<=10) {
  NN = neuralnet(ClassH + ClassL + ClassM ~ gender + raisedhands + VisITedResources + AnnouncementsView
                 + Discussion + ParentAnsweringSurvey + ParentschoolSatisfaction + StudentAbsenceDays, 
                 data = Train, hidden=i, err.fct = "ce", linear.output = F, stepmax = 1e07)
  pre = compute(NN, Test[,-c(1:3)])
  nn = ifelse(pre$net.result[,c(1,2,3)]>0.5,1,0)
  Errors1 = mean(Test[,c("ClassH", "ClassL", "ClassM")] != nn)
  bucket_result = c(bucket_result, Errors1)
  x_bucket = c(x_bucket,i)
  i = i + 1
  print(i)
}
plot(x_bucket, bucket_result,type="l",ylab="Errors", xlab="Hiddens",
     main="Error Rate for varying Hiddens")

NN = neuralnet(ClassH + ClassL + ClassM ~ gender + raisedhands + VisITedResources + AnnouncementsView
               + Discussion + ParentAnsweringSurvey + ParentschoolSatisfaction + StudentAbsenceDays, 
               data = Train, hidden=2, err.fct = "ce", linear.output = F, stepmax = 1e07)
plot(NN)

#Best Treshold is 0.4
bucket_result = numeric()
x_bucket = numeric()
i = 0
while (i<=1) {
  nn = ifelse(NN$net.result[[1]][,c(1,2,3)]>i,1,0)
  Errors1 = mean(Train[,c("ClassH", "ClassL", "ClassM")] != nn)
  bucket_result = c(bucket_result, Errors1)
  x_bucket = c(x_bucket,i)
  i = i + 0.1
}
plot(x_bucket, bucket_result,type="l",ylab="Errors", xlab="treshold",
     main="Error Rate for Test set")

#Predicting. 83% Accuracy. Usage of Ranom forest gives 75%
pre = compute(NN, Test[,-c(1:3)])
nn = ifelse(pre$net.result[,c(1,2,3)]>0.4,1,0)
Errors1 = mean(Test[,c("ClassH", "ClassL", "ClassM")] != nn)
1- Errors1
nn
Test[,c("ClassH", "ClassL", "ClassM")]

############### useful example for later ################################
########################################################################
########################################################################

#Choosing the best treshold. UNFORTUNATELLY, IT TAKES VERY LONG TIME. 
#Thebest Thershold is 0.4

#bucket_result = numeric()
#x_bucket = numeric()
#i = 0
#while (i<=1) {
  #for (j in 1:10) {
   # split = sample.split(edu$Class, SplitRatio = 0.7)
    #Train = subset(sub, split == TRUE)
    #NN = neuralnet(ClassH + ClassL + ClassM ~ gender + raisedhands + VisITedResources + AnnouncementsView
                  # + Discussion + ParentAnsweringSurvey + ParentschoolSatisfaction + StudentAbsenceDays, 
                  # data = Train, hidden=2, err.fct = "ce", linear.output = F, stepmax = 1e06)
    #calculate accuracy
   # nn = ifelse(NN$net.result[[1]]>i,1,0)
    #Errors1 = mean(Train[,c("ClassH", "ClassL", "ClassM")] != nn)
    #br = c(bucket_result, Errors1)
#  }
#  Error = mean(Errors1)
#  bucket_result = c(bucket_result, Errors)
#  x_bucket = c(x_bucket,i)
#  i = i + 0.1
#}
#plot(x_bucket, bucket_result,type="l",ylab="Errors", xlab="treshold",
#     main="Accuracy Rate for varying Minbucket")

########################################################################
########################################################################
########################################################################