\name{CNpreprocessing}
\alias{CNpreprocessing}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{
Pre-process DNA copy number (CN) data for detection of CN events.
}
\description{
Description: The package evaluates DNA copy number data, using both their 
intitial form (copy number as a noisy function of genomic position) and their
approximation by a piecewise-constant function (segmentation), for the purpose
of identifying genomic regions where the copy number differs from the norm.
}
\usage{
CNpreprocessing(segall, ratall = NULL, idcol = NULL, startcol = NULL, 
endcol = NULL, medcol = NULL, madcol = NULL, errorcol = NULL, 
chromcol = NULL, bpstartcol = NULL, bpendcol = NULL, annot = NULL, 
annotstartcol = NULL, annotendcol = NULL, annotchromcol = NULL, 
useend = F, blsize = NULL, minjoin = NULL, ntrial = 10, bestbic = -1e+07, 
modelNames = "E", cweight = NULL, bstimes = NULL, chromrange = NULL, 
myseed = 123, distrib = c("vanilla", "Rparallel"), njobs = 1, 
normalength = NULL, normalmedian = NULL, normalmad = NULL, 
normalerror = NULL)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{segall}{
A matrix or a data frame for segmented copy number profiles. It may have a 
character column, with a name specified by \code{idcol}, and/or numeric 
columns with names specified by \code{startcol, endcol, medcol, madcol,errorcol}  
\code{,chromcol, bpstartcol, bpendcol}. Each row of \code{segall} 
corresponds to a segment belonging to one of the profiles to be pre-processed.
}
  \item{ratall}{
A matrix whose rows correspond to genomic positions and columns to copy number
profiles. Its matrix elements are functions of copy number, most often
log ratios of copy number to the expected standard value, such as 2 in diploid 
genomes.
}
  \item{idcol}{
A character string specifying the name for the column in \code{segall} 
tabulating the profile IDs.
}
  \item{startcol, endcol}{
Character strings specifying the names of columns in \code{segall} that 
tabulate the (integer) start and end postions of each segment in internal 
units such as probe numbers for data of CGH microarray origin.
}
  \item{medcol, madcol, errorcol}{
Character strings specifying the names of columns in \code{segall} that,
for the function of copy number used in the study (typically log ratios),
tabulate the (numeric) values for the function (\code{medcol}), a measure
of its spread (\code{madcol}) and its error (\code{errorcol}) for the segment.
}
  \item{chromcol}{
A character string specifying the name for the column in \code{segall} 
tabulating the (integer) chromosome number for each segment.
}
  \item{bpstartcol, bpendcol}{
Character strings specifying the names of columns in \code{segall} that 
tabulate the (integer) genomic start and end coordinates of each segment.
}
  \item{annot}{
A matrix or a data frame that contains the annotation for the copy number 
measurement platform in the study. It is generally expected to contain columns
with names specified by \code{annotstartcol, annotendcol, annotchromcol}.
}
  \item{annotstartcol, annotendcol, annotchromcol}{
Character strings specifying the names of columns in \code{annot} that 
tabulate the (integer) genomic start and end coordinates and the chromosome
number for each copy number measuring unit, such as a probe in case of CGH
microarrays.
}
  \item{useend}{
A single logical value specifying whether the segment end positions as given by
the \code{bpendcol} of \code{segall} are to be looked up in the 
\code{annotendcol} column of \code{annot} (if \code{useend=TRUE}) or in the
\code{annotstartcol} column (default).
}
  \item{blsize}{
A single integer specifying the bootstrap sampling rate of segment medians to 
generate input for model-based clustering. The number of times a segment is 
sampled is then given by the (integer) division of the segment length in 
internal units by \code{blsize}.
}
  \item{minjoin}{
A single numeric value between 0 and 1 specifying the degree of overlap above 
which two clusters will be joined into one. 
}
  \item{ntrial}{
A single integer specifying the number of times a model-based clustering is
attempted for each profile in order to achieve the highest Bayesian information
criterion (BIC).
}
  \item{bestbic}{
A single numeric value for initalizing BIC maximization. A large negative value
is recommended. The default is \code{-1e7}.
}
  \item{modelNames}{
A vector of character strings specifying the names of models to be used in
model-based clustering (see package \code{mclust} for further details). The
default is \code{"E"}.
}
  \item{cweight}{
A single numeric value between 0 and 1 specifying the minimal share of the 
central cluster in each profile.
}
  \item{bstimes}{
A single integer value specifying the number of time the median of each segment
is sampled in order to predict the cluster assignment for the segment.
}
  \item{chromrange}{
A numeric vector enumerating chromosomes from which segments are to be used for
initial model-based clustering.
}
  \item{myseed}{
A single integer value to seed the random number generator.
}
  \item{distrib}{
One of \code{"vanilla", "Rparallel"} to specify the distributed
computing option for the cluster assignment step. For \code{"vanilla"} (default)
no distributed computing is performed. For \code{"Rparallel"} the 
\code{parallel} package of \code{R} core is used for multi-core processing.
}
  \item{njobs}{
A single integer specifying the number of worker jobs to create in case of 
distributed computation.
}
  \item{normalength}{
An integer vector specifying the genomic lengths of segments in the normal 
reference data.
}
  \item{normalmedian, normalmad, normalerror}{
Numeric vectors, of the same length as \code{normalength}, specifying the 
segment values, value spreads and errors of the normal reference segments.
}
}
\details{
Depending on the availability of input, the function will perform the following
operations for each copy number profile.

If raw data are available in addition to segment start and end positions,
median and MAD of each segment will be computed. For each profile, bootstrap 
sampling of the segment median values will be performed, and the sample will be
used to estimate the error in the median for each segment. Model-dependent
clustering (fitting to a gaussian mixture) of the sample will be performed. 
The central cluster (the one nearest the expected unaltered value) will be 
identified and, if necessary, merged with adjacent clusters in order to
comprise the minimal required fraction of the data. Deviation of each segment
from the center, its probabilty to belong to the central cluster and its 
marginal probability in the central cluster will be computed.

If segment medians or median deviations are available or have been computed, 
and, in addition, genomic lengths and average values are given for a 
collection of segments with unaltered copy number, additional estimates will be
performed. If median values are available for the unaltered segments, the
marginal probability of the observed median or median deviation in the unaltered
set will be computed for each segment. Likewise, marginal probabilities for
median/MAD and/or median/error will be computed if these statistics are 
available. 
}
\value{
The input \code{segall} data frame to which some or all of the following columns
may be bound, depending on the availability of input:
%%  ~Describe the value returned
%%  If it is a LIST, use
\item{segmedian}{Median function of copy number}
\item{segmad}{MAD for the function of copy number}
\item{mediandev}{median function of copy number relative to its central value}
\item{segerr}{error estimate for the function of copy number}
\item{segz}{the probability that the segment is in the central cluster}
\item{marginalprob}{marginal probability for the segment in the central cluster}
\item{negtail}{the probability of finding the deviation as observed or larger 
in a collection of central segments}
\item{negtailnormad}{the probability of finding the deviation/MAD as observed 
or larger in a collection of central segments}
\item{negtailnormerror}{the probability of finding the deviation/error as 
observed or larger in a collection of central segments}
}
\author{
Alex Krasnitz
}
\examples{
data(segexample)
data(ratexample)
data(normsegs)
#small toy example
segtable<-CNpreprocessing(segall=segexample[segexample[,"ID"]=="WZ1",],
ratall=ratexample,"ID","start","end",chromcol="chrom",bpstartcol="chrom.pos.start",
bpendcol="chrom.pos.end",blsize=50,minjoin=0.25,cweight=0.4,bstimes=50,
chromrange=1:3,distrib="Rparallel",njobs=2,modelNames="E",
normalength=normsegs[,1],normalmedian=normsegs[,2])
\dontrun{
#Example 1: 5 whole genome analysis, choosing the right format of arguments
segtable<-CNpreprocessing(segall=segexample,ratall=ratexample,"ID","start","end",
chromcol="chrom",bpstartcol="chrom.pos.start",bpendcol="chrom.pos.end",blsize=50,
minjoin=0.25,cweight=0.4,bstimes=50,chromrange=1:22,distrib="Rparallel",njobs=40,
modelNames="E",normalength=normsegs[,1],normalmedian=normsegs[,2])
#Example 2: how to use annotexample, when segment table does not have columns of 
#integer postions in terms of  measuring units(probes), such as "mysegs" below
mysegs<-segexample[,c(1,5:12)]
data(annotexample)
segtable<-CNpreprocessing(segall=mysegs,ratall=ratexample,"ID",chromcol="chrom",
bpstartcol="chrom.pos.start",bpendcol="chrom.pos.end",annot=annotexample,
annotstartcol="CHROM.POS",annotendcol="CHROM.POS",annotchromcol="CHROM",
blsize=50,minjoin=0.25,cweight=0.4,bstimes=50,chromrange=1:22,distrib="Rparallel",
njobs=40,modelNames="E",normalength=normsegs[,1],normalmedian=normsegs[,2])
}
}
