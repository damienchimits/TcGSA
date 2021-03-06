#'Parallel computing the Likelihood Ratios for the Gene Sets under Scrutiny
#'
#'A parallel version of the function \code{\link{TcGSA.LR}} to be used on a
#'cluster of computing processors.  This function computes the Likelihood
#'Ratios for the gene sets under scrutiny, as well as estimations of genes
#'dynamics inside those gene sets through mixed models.
#'
#'This Time-course Gene Set Analysis aims at identifying gene sets that are not
#'stable over time, either homogeneously or heterogeneously (see \emph{Hejblum
#'et al, 2012}) in terms of their probes.  And when the argument
#'\code{separatePatients} is \code{TRUE}, instead of identifying gene sets that
#'have a significant trend over time (possibly with probes heterogeneity of
#'this trend), \emph{TcGSA} identifies gene sets that have significantly
#'different trends over time depending on the patient.
#'
#'If the \code{monitorfile} argument is a character string naming a file to
#'write into, in the case of a new file that does not exist yet, such a new
#'file will be created. A line is written each time one of the gene sets under
#'scrutiny has been analysed (i.e. the two mixed models have been fitted, see
#'\code{\link{TcGSA.LR}}) by one of the parallelized processors.
#'
#'@aliases TcGSA.LR.parallel
#'
#'@param Ncpus The number of processors available on the cluster.
#'
#'@param type_connec The type of connection between the processors. Supported
#'cluster types are \code{"SOCK"}, \code{"PVM"}, \code{"MPI"}, and
#'\code{"NWS"}. See also \code{\link[parallel:makeCluster]{makeCluster}}.
#'
#'@param expr 
#'a matrix or dataframe of gene expression.  Its dimension are
#'\eqn{n}x\eqn{p}, with the \eqn{p} samples in column and the \eqn{n} genes in
#'row.
#'
#'@param gmt 
#'a \bold{gmt} object containing the gene sets definition.  See
#'\code{\link[GSA:GSA.read.gmt]{GSA.read.gmt}} and definition on 
#'\href{http://www.broadinstitute.org/cancer/software/gsea/wiki/index.php/Data_formats}{www.broadinstitute.org}.
#'
#'@param design
#'a matrix or dataframe containing the experimental variables that used in the model,
#'namely \code{subject_name}, \code{time_name}, and \code{covariates_fixed} 
#'and \code{time_covariates} if applicable.  Its dimension are \eqn{p}x\eqn{m} 
#'and its row are is in the same order as the columns of \code{expr}.
#'
#'@param subject_name
#'the name of the factor variable from \code{design} that contains the information on 
#'the repetition units used in the mixed model, such as the patient identifiers for instance.  
#'Default is \code{'Patient_ID'}.  See Details.
#'
#'@param time_name
#'the name of the numeric or factor variable from \code{design} contains 
#'the information on the time replicates (the time points at which gene 
#'expression was measured).  Default is \code{'TimePoint'}.  See Details.
#'
#'@param crossedRandom
#'logical flag indicating wether the random effects of the subjects and of the time points
#'should be modeled as one crossed random effect or as two separated random effects.  
#'Default is \code{FALSE}. See details.
#'
#'@param covariates_fixed
#'a character vector with the names of numeric or factor variables from the \code{design} 
#'matrix that should appear as fixed effects in the model.  See details.
#'Default is \code{""}, which corresponds to no covariates in the model.
#'
#'@param time_covariates
#'the name of a numeric variable from \code{design} that contains 
#'the information on the time replicates (the time points at which gene 
#'expression was measured).  Default is \code{'TimePoint'}.  See Details.
#'
#'@param time_crossedRandom
#'logical flag indicating wether the random coefficients of the subjects and of the time points
#'should be modeled as one crossed random coefficient or as two separated random coefficients
#'in the time function.  
#'Default is \code{FALSE}.
#'
#'@param time_func 
#'the form of the time trend. Can be either one of \code{"linear"},
#'\code{"cubic"}, \code{"splines"} or specified by the user, or the column name of 
#'a factor variable from \code{design}. If specified by the user, 
#'it must be as an expression using only names of variables from the \code{design} matrix 
#'with only the three following operators: \code{+}, \code{*}, \code{/} . 
#'The \code{"splines"} form corresponds to the natural cubic B-splines 
#'(see also \code{\link[splines:ns]{ns}}).  If there are only a few timepoints, 
#'a \code{"linear"} form should be sufficient. Otherwise, the \code{"cubic"} form is 
#'more parsimonious than the \code{"splines"} form, and should be sufficiently flexible.
#'If the column name of a factor variable from \code{design} is supplied, 
#'then time is considered as discrete in the analysis.
#'If the user specify a formula using column names from design, both factor and numeric
#'variables can be used.
#'
#'@param minGSsize 
#'the minimum number of genes in a gene set.  If there are
#'less genes than this number in one of the gene sets under scrutinity, the
#'Likelihood Ratio of this gene set is not computed (the mixed model are not
#'fitted). Default is \code{10} genes as the minimum.
#'
#'@param maxGSsize 
#'the maximum number of genes in a gene set.  If there are
#'more genes than this number in one of the gene sets under scrutinity, the
#'Likelihood Ratio of this gene set is not computed (the mixed model are not
#'fitted).  This is to avoid very long computation times.  Default is
#'\code{500} genes as the maximum.
#'
#'@param group_name 
#'in the case of several treatment groups, the name of a factor variable 
#'from the \code{design} matrix.  It indicates to which treatment group each sample
#' belongs to.  Default is \code{""}, which means that there is only one 
#' treatment group.  See Details.
#'
#'@param separateSubjects
#'logical flag indicating that the analysis identifies
#'gene sets that discriminates patients rather than gene sets than have a
#'significant trend over time.  Default is \code{FALSE}.  See Details.
#'
#'@param monitorfile
#'a writable \link{connections} or a character string naming a file to write into, 
#'to monitor the progress of the analysis.  
#'Default is \code{""} which is no monitoring.  See Details.
#'
#'@return \code{TcGSA.LR} returns a \code{tcgsa} object, which is a list with
#'the 5 following elements:
#'\itemize{
#'\item fit a data frame that contains the 7 following variables:
#'\itemize{ 
#'\item \code{LR}: the likelihood ratio between the model under the
#'null hypothesis and the model under the alternative hypothesis.  
#'\item \code{AIC_H0}: AIC criterion for the model under the null hypothesis.
#'\item \code{AIC_H1}: AIC criterion for the model under the alternative hypothesis.
#'\item \code{BIC_H0}: BIC criterion for the model under the null hypothesis.
#'\item \code{BIC_H1}: BIC criterion for the model the alternative hypothesis.
#'\item \code{CVG_H0}: convergence status of the model under the null hypothesis.
#'\item \code{CVG_H1}: convergence status of the model under the alternative
#'hypothesis.
#'}
#'\item \code{time_func}: a character string passing along the value of the
#'\code{time_func} argument used in the call.
#'\item \code{GeneSets_gmt}: a \code{gmt} object passing along the value of the
#'\code{gmt} argument used in the call.
#'\item \code{group.var}: a factor passing along the \code{group_name} variable
#'from the \code{design} matrix.
#'\item \code{separateSubjects}: a logical flag passing along the value of the
#'\code{separateSubjects} argument used in the call.
#'\item \code{Estimations}: a list of 3 dimensions arrays.  Each element of the
#'list (i.e. each array) corresponds to the estimations of gene expression
#'dynamics for each of the gene sets under scrutiny (obtained from mixed
#'models).  The first dimension of those arrays is the genes included in the
#'concerned gene set, the second dimension is the \code{Patient_ID}, and the
#'third dimension is the \code{TimePoint}.  The values inside those arrays are
#'estimated gene expressions.
#'\item \code{time_DF}: the degree of freedom of the natural splines functions
#'}
#'
#'@author Boris P. Hejblum, Damien Chimits
#'
#'@seealso \code{\link{summary.TcGSA}}, \code{\link{plot.TcGSA}}
#'
#'@references Hejblum, B.P., Skinner, J., Thiebaut, R., 2014, TcGSA: a gene set approach for longitudinal gene expression data analysis, \bold{submitted}.
#'
#'@examples
#'
#'data(data_simu_TcGSA)
#'
#'tcgsa_sim_1grp <- TcGSA.LR(expr=expr_1grp, gmt=gmt_sim, design=design, 
#'                           subject_name="Patient_ID", time_name="TimePoint",
#'                           time_func="linear", crossedRandom=FALSE)
#'                           
#'\dontrun{ 
#'require(doSNOW)
#'tcgsa_sim_1grp <- TcGSA.LR.parallel(Ncpus = 2, type_connec = 'SOCK',
#'                             expr=expr_1grp, gmt=gmt_sim, design=design, 
#'                             subject_name="Patient_ID", time_name="TimePoint",
#'                             time_func="linear", crossedRandom=FALSE, 
#'                             separateSubjects=TRUE)
#'}
#'tcgsa_sim_1grp
#'summary(tcgsa_sim_1grp)
#'     
#'
#'

TcGSA.LR.parallel <-
	function(Ncpus, type_connec, 
			 expr, gmt, design, subject_name="Patient_ID", time_name="TimePoint", crossedRandom_fixed=FALSE,time_crossedRandom=FALSE,
			 covariates_fixed="", time_covariates="",
			 time_func = "linear", group_name="", separateSubjects=FALSE,
			 minGSsize=10, maxGSsize=500,
			 monitorfile=""){
		
		library(doSNOW)
		
		if(group_name!="" && separateSubjects){
			stop("'separateSubjects' is TRUE while 'group_name' is not \"\".\n This is an attempt to separate subjects in a multiple group setting.\n This is not handled by the TcGSA.LR function.\n\n")
		}
		
		#   library(GSA)
		#   library(lme4)
		#   library(reshape2)
		#   require(splines)
		LR <- numeric(length(gmt$genesets))
		AIC_H0 <- numeric(length(gmt$genesets))
		AIC_H1 <- numeric(length(gmt$genesets))
		BIC_H0 <- numeric(length(gmt$genesets))
		BIC_H1 <- numeric(length(gmt$genesets))
		CVG_H0 <- numeric(length(gmt$genesets))
		CVG_H1 <- numeric(length(gmt$genesets))
		estim_expr <- list()
		
		my_formul <- TcGSA.formula(design=design, subject_name=subject_name, time_name=time_name,  
								   covariates_fixed=covariates_fixed, time_covariates=time_covariates, group_name=group_name,
								   separateSubjects=separateSubjects, crossedRandom_fixed=crossedRandom_fixed,
								   time_func=time_func,time_crossedRandom)
		
		time_DF <- my_formul[["time_DF"]]
		
		
		
		cl <- makeCluster(Ncpus, type = type_connec)
		registerDoSNOW(cl)
		
		res_par <- foreach(gs=1:length(gmt$genesets), .packages=c("lme4", "reshape2", "splines"), .export=c("TcGSA.dataLME")) %dopar% {
			probes <- intersect(gmt$genesets[[gs]], rownames(expr))
			
			if(length(probes)>0 && length(probes)<=maxGSsize && length(probes)>=minGSsize){                                                       
				expr_temp <- t(expr[probes, ])
				rownames(expr_temp) <- NULL
				data_lme  <- TcGSA.dataLME(expr=expr_temp, design=design, subject_name=subject_name, time_name=time_name, 
										   covariates_fixed=covariates_fixed, time_covariates=time_covariates,
										   group_name=group_name, time_func=time_func)
				
				if(length(levels(data_lme$probe))>1){
					lmm_H0 <- tryCatch(lmer(formula =my_formul[["H0"]]["reg"], REML=FALSE, data=data_lme),
									   error=function(e){NULL})
					lmm_H1 <- tryCatch(lmer(formula =my_formul[["H1"]]["reg"], REML=FALSE, data=data_lme),
									   error=function(e){NULL})
				}
				else{
					lmm_H0 <- tryCatch(lmer(formula =my_formul[["H0"]]["1probe"], REML=FALSE, data=data_lme),
									   error=function(e){NULL})
					lmm_H1 <- tryCatch(lmer(formula =my_formul[["H1"]]["1probe"], REML=FALSE, data=data_lme),
									   error=function(e){NULL})
				}
				
				if (!is.null(lmm_H0) & !is.null(lmm_H1)) {
					LR <- deviance(lmm_H0, REML=FALSE) - deviance(lmm_H1, REML=FALSE)
					AIC_H0 <- AIC(lmm_H0)
					AIC_H1 <- AIC(lmm_H1)
					BIC_H0 <- BIC(lmm_H0)
					BIC_H1 <- BIC(lmm_H1)
					CVG_H0 <- lmm_H0@optinfo["conv"]
					CVG_H1 <- lmm_H1@optinfo["conv"]
					
					estims <- cbind.data.frame(data_lme, "fitted"=fitted(lmm_H1))
					estims_tab <- acast(data=estims, formula = as.formula(paste("probe", subject_name, "t1", sep="~")), value.var="fitted")
					# drop = FALSE by default, which means that missing combination will be kept in the estims_tab and filled with NA
					
					if(time_name %in% colnames(estims)){
						time_points <- levels(as.factor(design[,which(colnames(design)==time_name)]))
					}
					dimnames(estims_tab)[[3]] <- as.numeric(levels(as.factor(design[,which(colnames(design)==time_name)])))
					# dimnames(estims_tab)[[3]] <- as.numeric(dimnames(estims_tab)[[3]])*10
					estim_expr <- estims_tab
				} 
				else {
					LR <- NA
					AIC_H0 <- NA
					AIC_H1 <- NA
					BIC_H0 <- NA
					BIC_H1 <- NA
					CVG_H0 <- NA
					CVG_H1 <- NA
					
					estims <- cbind.data.frame(data_lme, "fitted"=NA)
					estims_tab <- acast(data=estims, formula = as.formula(paste("probe", subject_name, "t1", sep="~")), value.var="fitted")
					if(time_name %in% colnames(estims)){
						time_points <- levels(as.factor(design[,which(colnames(design)==time_name)]))
					}
					dimnames(estims_tab)[[3]] <- as.numeric(levels(as.factor(design[,which(colnames(design)==time_name)])))
					# dimnames(estims_tab)[[3]] <- as.numeric(dimnames(estims_tab)[[3]])*10
					estim_expr <- estims_tab
					cat("Unable to fit the mixed models for this gene set\n")
				}
				
				#		CONVERGENCE DIAGNOSTICS IN LME4
				#       "3" = "X-convergence (3)",
				#       "4" = "relative convergence (4)",
				#       "5" = "both X-convergence and relative convergence (5)",
				#       "6" = "absolute function convergence (6)",
				# 
				#       "7" = "singular convergence (7)",
				#       "8" = "false convergence (8)",
				#       "9" = "function evaluation limit reached without convergence (9)",
				#       "10" = "iteration limit reached without convergence (9)",
				#       "14" = "storage has been allocated (?) (14)",
				# 
				#       "15" = "LIV too small (15)",
				#       "16" = "LV too small (16)",
				#       "63" = "fn cannot be computed at initial par (63)",
				#       "65" = "gr cannot be computed at initial par (65)")
				#
				
			}
			else{
				LR <- NA
				AIC_H0 <- NA
				AIC_H1 <- NA
				BIC_H0 <- NA
				BIC_H1 <- NA
				CVG_H0 <- NA
				CVG_H1 <- NA
				
				estim_expr <- NA
				cat("The size of the gene set",  gmt$geneset.names[[gs]], "is problematic (too many or too few genes)\n")
			}
			
			line_number <- 0
			try(line_number <- length(readLines(monitorfile)), silent=TRUE)
			cat(paste(line_number+1,"/", length(gmt$genesets)," gene sets analyzed (geneset ", gs, ")\n", sep=""), file=monitorfile, append = TRUE)
			
			res <- list("LR"=LR, "AIC_H0"=AIC_H0, "AIC_H1"=AIC_H1, "BIC_H0"=BIC_H0, "BIC_H1"=BIC_H1, "CVG_H0"=CVG_H0, "CVG_H1"=CVG_H1, "estim_expr"=estim_expr)
		}
		
		
		cat("Combining the results...")
		for (gs in 1:length(gmt$genesets)){
			LR[gs] <- res_par[[gs]][["LR"]]
			AIC_H0[gs] <- res_par[[gs]][["AIC_H0"]]
			AIC_H1[gs] <- res_par[[gs]][["AIC_H1"]]
			BIC_H0[gs] <- res_par[[gs]][["BIC_H0"]]
			BIC_H1[gs] <- res_par[[gs]][["BIC_H1"]]
			CVG_H0[gs] <- res_par[[gs]][["CVG_H0"]]
			CVG_H1[gs] <- res_par[[gs]][["CVG_H1"]]
			estim_expr[[gs]] <- res_par[[gs]][["estim_expr"]]
		}
		
		if(group_name==""){
			gv <- NULL
		} else{
			gv <- design[,group_name]
		}
		
		tcgsa <- list("fit"=as.data.frame(cbind(LR, AIC_H0, AIC_H1, BIC_H0, BIC_H1, CVG_H0, CVG_H1)), "time_func"=time_func, "GeneSets_gmt"=gmt, 
					  "group.var"=gv, "separateSubjects"=separateSubjects, "Estimations"=estim_expr, 
					  "time_DF"=time_DF
		)
		class(tcgsa) <- "TcGSA"
		stopCluster(cl)
		converge_H0 <- 0
		converge_H1 <- 0
		nb_models_H0 <- 0
		nb_models_H1 <- 0
		for (i in 1 : length(tcgsa$fit$CVG_H0)){
			if(!is.na(tcgsa$fit$CVG_H0[[i]][1])){
				nb_models_H0 <- nb_models_H0 + 1
				if(tcgsa$fit$CVG_H0[[i]][1] == 0){
					converge_H0 <- converge_H0 + 1
				}
			}
		}
		for (i in 1 : length(tcgsa$fit$CVG_H1)){
			if(!is.na(tcgsa$fit$CVG_H1[[i]][1])){
				nb_models_H1 <- nb_models_H1 + 1
				if(tcgsa$fit$CVG_H1[[i]][1] == 0){
					converge_H1 <- converge_H1 + 1
				}
			}
		}
		cat(converge_H0, "models out of", nb_models_H0 , "have converged under H0\n", "and", converge_H1, "models out of", nb_models_H1, "have converged under H1\n")
		return(tcgsa)
	}

