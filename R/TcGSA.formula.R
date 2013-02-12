

TcGSA.formula <- 
	function(design, subject_name="Patient_ID", time_name="TimePoint", crossedRandom=FALSE,
					 covariates_fixed="", time_covariates="",
					 time_func = "linear", group.var=NULL, separateSubjects=FALSE){
		
		# TIME function
		if(time_func=="linear"){
			time <- "t1"
		}
		else if(time_func=="cubic"){
			time <- "t1 + t2 + t3"
		}
		else if(time_func=="splines"){
			nk = ceiling(length(unique(design[,time_name]))/4)
			noeuds = quantile(design[,time_name], probs=c(1:(nk))/(nk+1))
			NCsplines <- as.data.frame(ns(design[,time_name], knots = noeuds, Boundary.knots = range(design[,time_name]), intercept = FALSE))
			time <- paste(" + spline_t", colnames(NCsplines), collapse="", sep="")
			#time <- paste(" + spline_t",1:(nk+1) , sep="", collapse="")
		}
		else{
			time <- time_func
			#a user specified function of time. 
			#This must be an expression involving only columnnames of the design matrix
		}
		
		
		
		
		# Covariates
		if(covariates_fixed[1]!=""){
			covariates_fixed <- paste(" + ", covariates_fixed, collapse="", sep="")
		}
		
		if(time_covariates[1]!=""){
			time_split <- trim(str_split(paste("+", time, collapse=" "), "\\+")[[1]])
			if(length(which(time_split==""))>0){time_split <- time_split[-which(time_split=="")]}
			tc <- NULL
			for (c in time_covariates){
				tc <- paste(tc, paste(" +", paste(time_split, c, sep=":", collapse=" + "), collapse=" "), sep="")
			}
			time_covariates <- tc
		}
		
		
		
		if (!crossedRandom){
			if(is.null(group.var) & !separateSubjects){
				formula_H0 = paste("expression ~ 1 + (1|probe)", covariates_fixed,
													" + (1|", subject_name, ")", sep="")
				
				formula_H1 = paste("expression ~ 1 + (1|probe)", covariates_fixed, " + ", time, time_covariates,
													" + (", time, "|probe) + (1|", subject_name, ")", sep="")
				
				formula_H0_1probe = paste("expression ~ 1", covariates_fixed,
																 " + (1|", subject_name, ")", sep="")
				
				formula_H1_1probe = paste("expression ~ 1", covariates_fixed,  " + ", time, time_covariates,
													" + (1|", subject_name, ")", sep="")
				
			}
			else if(is.null(group.var) & separateSubjects){
				formula_H0 = paste("expression ~ 1 + (1|probe)", covariates_fixed,
													 " + (1|", subject_name, ")", sep="")
				
				formula_H1 = paste("expression ~ 1 + (1|probe)", covariates_fixed, " + ", time, time_covariates,
													 " + (", time, "|", subject_name, ") + (1|", subject_name, ")", sep="")
				
				formula_H0_1probe = paste("expression ~ 1", covariates_fixed,
																	" + (1|", subject_name, ")", sep="")
				
				formula_H1_1probe = paste("expression ~ 1", covariates_fixed, " + ", time, time_covariates,
																	" + (", time, "|", subject_name, ") + (1|", subject_name, ")", sep="")
				
			}
			else if(!is.null(group.var) & !separateSubjects){
				formula_H0 = paste("expression ~ 1 + (1|probe) + Group", covariates_fixed, " + ", time, time_covariates,
													 " + (", time, "|probe) + (1|", subject_name, ")", sep="")
				
				formula_H1 = paste("expression ~ 1 + (1|probe) + Group", covariates_fixed, " + ", time, " + ", paste(time, ":Group", sep=""), time_covariates,
													 " + (", paste(time, ":Group", sep=""), "|probe) + (1|", subject_name, ")", sep="")
				
				formula_H0_1probe = paste("expression ~ 1 + Group", covariates_fixed, " + ", time, time_covariates,
																	" + (1|", subject_name, ")", sep="")
				
				formula_H1_1probe = paste("expression ~ 1 + Group", covariates_fixed, " + ", time, " + ", paste(time, ":Group", sep=""), time_covariates,
																	" + (1|", subject_name, ")", sep="")
				
			}
		}
		else{	
			if(is.null(group.var) & !separateSubjects){
				formula_H0 = paste("expression ~ 1 + probe", covariates_fixed,
													 " + (1|", subject_name, ":probe)", sep="")
				
				formula_H1 = paste("expression ~ 1 + probe", covariates_fixed, " + ", time, time_covariates,
													 " + (", time, "|probe) + (1|", subject_name, ":probe)", sep="")
				
				formula_H0_1probe = paste("expression ~ 1", covariates_fixed,
																	" + (1|", subject_name, ")", sep="")
				
				formula_H1_1probe = paste("expression ~ 1", covariates_fixed,  " + ", time, time_covariates,
																	" + (1|", subject_name, ")", sep="")
				
			}
			else if(is.null(group.var) & separateSubjects){
				formula_H0 = paste("expression ~ 1 + probe", covariates_fixed,
													 " + (1|", subject_name, ":probe)", sep="")
				
				formula_H1 = paste("expression ~ 1 + probe", covariates_fixed, " + ", time, time_covariates,
													 " + (", time, "|", subject_name, ") + (1|", subject_name, ":probe)", sep="")
				
				formula_H0_1probe = paste("expression ~ 1", covariates_fixed,
																	" + (1|", subject_name, ")", sep="")
				
				formula_H1_1probe = paste("expression ~ 1", covariates_fixed, " + ", time, time_covariates,
																	" + (", time, "|", subject_name, ") + (1|", subject_name, ")", sep="")
				
			}
			else if(!is.null(group.var) & !separateSubjects){
				formula_H0 = paste("expression ~ 1 + probe + Group", covariates_fixed, " + ", time, time_covariates,
													 " + (", time, "|probe) + (1|", subject_name, ":probe)", sep="")
				
				formula_H1 = paste("expression ~ 1 + probe + Group", covariates_fixed, " + ", time, " + ", paste(time, ":Group", sep=""), time_covariates,
													 " + (", paste(time, ":Group", sep=""), "|probe) + (1|", subject_name, ":probe)", sep="")
				
				formula_H0_1probe = paste("expression ~ 1 + Group", covariates_fixed, " + ", time, time_covariates,
																	" + (1|", subject_name, ")", sep="")
				
				formula_H1_1probe = paste("expression ~ 1 + Group", covariates_fixed, " + ", time, " + ", paste(time, ":Group", sep=""), time_covariates,
																	" + (1|", subject_name, ")", sep="")
				
			}
		}
		return(list("H0"=c("reg"=formula_H0, "1probe"=formula_H0_1probe), "H1"=c("reg"=formula_H1, "1probe"=formula_H1_1probe)))	
	}

