FitPlot1<-function(dat1, k){
  
  require(metafor)
  require(ggplot2)
  
  #1
  list.results<-list()
  list.results1<-list()
  #2
  list.data<-list()
  list.data1<-list()
  #3
  list.figures<-list()
  list.figures1<-list()
  
  j<-0#TRAITS
  for(j in 1:length(TRAIT)){
    
    i<-0 #MEASCAT
    for(i in 1:length(MEASCAT)){
      
      #subset data by the current effect size measurement and trait value
      dat2<-subset(dat1, measCat==MEASCAT[i] & traitCat==TRAIT[j])
      
      #simplify dataframe
      paperID<-dat2$paperID
      obsID<-dat2$obsID
      invGenera<-dat2$invGenera
      xval<-dat2[,PLANT[k]]
      yi<-dat2$yi
      vi<-dat2$vi
      data<-data.frame(paperID, obsID, invGenera, xval, yi, vi)
      data1<-data[!is.na(data$yi) & !is.na(data$vi) & !is.na(data$xval),] #remove NAs for base dataset
      
      #fit a meta-regression with XCAT as x axis
      resPlot <- rma.mv(yi, vi, 
                        mods = ~ 1 + xval, 
                        random=list(~1 | paperID, ~1 | obsID), 
                        data=data1, slab=as.character(obsID), method='ML', control=list(maxit=1000))
      resPlot0 <- rma.mv(yi, vi, 
                         mods = ~ 1, 
                         random=list(~1 | paperID, ~1 | obsID), 
                         data=data1, slab=as.character(obsID), method='ML', control=list(maxit=1000))
      result<-SaveFitStats(res=resPlot, res0=resPlot0, k, j, i)
      wi<-1/sqrt(data1$vi)
      data1$size<-0.5 + 3.0 * (wi - min(wi))/(max(wi) - min(wi)) #calculate point sizes
      
      pred<-predict(resPlot)
      data1$pred<-pred$pred
      data1$cr.lb<-pred$cr.lb
      data1$cr.ub<-pred$cr.ub
      data1$ci.lb<-pred$ci.lb
      data1$ci.ub<-pred$ci.ub
      
      #1. save the model fit results
      list.results[[i]] <- result
      
      #2. save the dataset used for plotting
      list.data[[i]] <- data1
      
      #make a plot panel of an effect size against an absolute trait value
      #ylab(paste(ylabs[i], 'Effect Size')) + xlab(paste(globalxlabs1[k], globalxlabs2[j])) +
      p<-ggplot(data1, aes(x=xval, y=yi)) + geom_point(shape=1, aes(size=size)) + 
        geom_abline(intercept = 0, slope=0, lty=2) + mytheme + 
        labs(x=NULL, y=NULL) +
        guides(size=FALSE)
      
      #add model fit if needed
      if(sum(result$pVal<0.1)>0){
        p<-p + 
          geom_ribbon(aes(ymin=ci.lb,ymax=ci.ub),alpha=0.3) +
          geom_ribbon(aes(ymin=cr.lb,ymax=cr.ub),alpha=0.3) +
          geom_line(aes(y=pred), color='blue', size=1) + 
          mytheme
      }
      if(k==3){
        p<-p+geom_vline(xintercept = 0, lty=2)
      }
      #3. save the plot panel
      list.figures[[i]]<-p
      
    }
    
    #1
    names(list.results)<-MEASCAT
    list.results1[[j]]<-list.results
    
    #2
    names(list.data)<-MEASCAT
    list.data1[[j]]<-list.data
    
    #3
    names(list.figures)<-MEASCAT
    list.figures1[[j]]<-list.figures
    
  }
  
  #1
  names(list.results1)<-TRAIT
  
  #2
  names(list.data1)<-TRAIT
  
  #3
  names(list.figures1)<-TRAIT
  
  #Save everything in a big list
  result.list<-list(results=list.results1, data=list.data1, figures=list.figures1)
  
  return(result.list)
}

