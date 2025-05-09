#' Read a .hic file and return Hi-C data as a dataframe
#' 
#' @usage readHic(
#'     file,
#'     chrom,
#'     chromstart = NULL,
#'     chromend = NULL,
#'     altchrom = NULL,
#'     altchromstart = NULL,
#'     altchromend = NULL,
#'     assembly = "hg38",
#'     resolution = "auto",
#'     res_scale = "BP",
#'     zrange = NULL,
#'     norm = "KR",
#'     matrix = "observed",
#'     params = NULL,
#'     quiet = FALSE
#' )
#'
#' @param file A character value specifying the path to the .hic file.
#' @param chrom Chromosome of data, as a string.
#' @param chromstart Integer start position on chromosome.
#' @param chromend Integer end position on chromosome.
#' @param altchrom Alternate chromosome for interchromosomal data,
#' as a string.
#' @param altchromstart Alternate chromosome integer start position
#' for interchromosomal data.
#' @param altchromend Alternate chromosome integer end position
#' for interchromosomal data.
#' @param assembly Default genome assembly as a string or a
#' \link[plotlandscaper]{assembly} object.
#' Default value is \code{assembly = "hg38"}.
#' @param resolution A numeric specifying the width of each pixel.
#' "auto" will attempt to choose a resolution in basepairs based on
#' the size of the region.
#' @param res_scale A character value specifying the resolution scale.
#' Default value is \code{res_scale = "BP"}. Options are:
#' \itemize{
#' \item{\code{"BP"}: }{Base pairs.}
#' \item{\code{"FRAG"}: }{Fragments.}
#' }
#' @param zrange A numeric vector of length 2 specifying the range of
#' interaction scores, where extreme values will be set to the max or min.
#' @param norm Character value specifying hic data normalization method.
#' This value must be found in the .hic file.
#' Default value is \code{norm = "KR"}.
#' @param matrix Character value indicating the type of matrix to output.
#' Default value is \code{matrix = "observed"}. Options are:
#' \itemize{
#' \item{\code{"observed"}: }{Observed counts.}
#' \item{\code{"oe"}: }{Observed/expected counts.}
#' \item{\code{"log2oe"}: }{Log2 transformed observed/expected counts.}
#' }
#' @param params An optional \link[plotlandscaper]{pgParams} object
#' containing relevant function parameters.
#' @param quiet A logical indicating whether or not to print messages.
#'
#' @return Returns a 3-column dataframe in sparse upper triangular
#' format with the following columns: \code{chrom}, \code{altchrom},
#' \code{counts}.
#' 
#' @examples 
#' hicFile <- system.file("extdata/test_chr22.hic", package="plotgardenerData")
#' 
#' ## Read in data for all chr22 file at 2.5Mb bp resolution
#' hicData <- readHic(file = hicFile, chrom = "22",
#'                     assembly = "hg19",
#'                     resolution = 2500000) 
#'                         
#' ## Read in region `chr22:20000000-47500000` at 100 Kb resolution
#' hicData10Kb <- readHic(file = hicFile, chrom = "22",
#'                         chromstart = 20000000, chromend = 47500000,
#'                         assembly = "hg19",
#'                         resolution = 100000)                     
#'
#' @seealso \link[strawr]{straw}
#'
#' @export
readHic <- function(file, chrom, chromstart = NULL, chromend = NULL,
                    altchrom = NULL, altchromstart = NULL,
                    altchromend = NULL, assembly = "hg38",
                    resolution = "auto", res_scale = "BP",
                    zrange = NULL, norm = "KR", matrix = "observed",
                    params = NULL, quiet = FALSE) {


    # =========================================================================
    # FUNCTIONS
    # =========================================================================

    ## Define a function that catches errors for readHic
    errorcheck_readHic <- function(hic, chrom, chromstart, chromend,
                                zrange, altchrom, altchromstart,
                                altchromend, norm, res_scale, assembly) {

        ## hic input needs to be a path to a .hic file
        if (!is(hic, "character")) {
            stop("Invalid input. Input needs to be a path to a .hic file.",
                call. = FALSE
            )
        }

        if ((file_ext(hic) != "hic")) {
            stop("Invalid input. File must have a \".hic\" extension",
                call. = FALSE
            )
        }
        
        ## Check that chrom is in file
        chroms <- strawr::readHicChroms(normalizePath(hic))[, "name"]
        if (!chrom %in% chroms){
            stop("`chrom` not found in file. Check file chromosome names",
                 " with `strawr::readHicChroms`.", call. = FALSE)
        }

        ## Genomic region
        regionErrors(chromstart = chromstart,
                    chromend = chromend)
        
        if (!is.null(altchrom)) {
            
            if (!altchrom %in% chroms){
                stop("`altchrom` not found in file. Check file chromosome names",
                     " with `strawr::readHicChroms`,", call. = FALSE)
            }
            

            ## Can't specify altchrom without a chrom
            if (is.null(chrom)) {
                stop("Specified \'altchrom\', but did not give \'chrom\'.",
                    call. = FALSE
                )
            }
            
            regionErrors(chromstart = altchromstart,
                        chromend = altchromend)
            
            ## If giving same chrom and altchrom, need to specify
            ## chromstart/chromend and altchromstart/altchromend
            
            if (chrom == altchrom) {
                if (is.null(chromstart) |
                    is.null(chromend) |
                    is.null(altchromstart) |
                    is.null(altchromend)) {
                    stop("If giving the same \'chrom\' and \'altchrom\', ",
                        "please specify \'chromstart\', \'chromend\', ",
                        "\'altchromstart\', and \'altchromend\'. ",
                        "If trying to get all interactions between one ",
                        "chromosome, just specify \'chrom\'.", call. = FALSE)
                }
            }
        }

        ## zrange errors
        rangeErrors(range = zrange)

        ## Check for valid "res_scale" parameter
        if (!(res_scale %in% c("BP", "FRAG"))) {
            stop("Invalid \'res_scale\'.  Options are \'BP\' and \'FRAG\'.",
                call. = FALSE
            )
        }
    }

    ## Define a function that determines a best resolution for size of region
    auto_resolution <- function(file, chromstart, chromend) {
        fileResolutions <- strawr::readHicBpResolutions(file)
        if (is.null(chromstart) & is.null(chromend)) {
            autoRes <- max(fileResolutions)
        } else {
            dataRange <- chromend - chromstart
            if (dataRange >= 150000000) {
                autoRes <- max(fileResolutions)
            } else if (dataRange >= 75000000 & dataRange < 150000000) {
                autoRes <- 250000
                autoRes <- fileResolutions[which(
                    abs(fileResolutions - autoRes) == min(
                        abs(fileResolutions - autoRes)
                    )
                )]
            } else if (dataRange >= 35000000 & dataRange < 75000000) {
                autoRes <- 100000
                autoRes <- fileResolutions[which(
                    abs(fileResolutions - autoRes) == min(
                        abs(fileResolutions - autoRes)
                    )
                )]
            } else if (dataRange >= 20000000 & dataRange < 35000000) {
                autoRes <- 50000
                autoRes <- fileResolutions[which(
                    abs(fileResolutions - autoRes) == min(
                        abs(fileResolutions - autoRes)
                    )
                )]
            } else if (dataRange >= 5000000 & dataRange < 20000000) {
                autoRes <- 25000
                autoRes <- fileResolutions[which(
                    abs(fileResolutions - autoRes) == min(
                        abs(fileResolutions - autoRes)
                    )
                )]
            } else if (dataRange >= 3000000 & dataRange < 5000000) {
                autoRes <- 10000
                autoRes <- fileResolutions[which(
                    abs(fileResolutions - autoRes) == min(
                        abs(fileResolutions - autoRes)
                    )
                )]
            } else {
                autoRes <- 5000
                autoRes <- fileResolutions[which(
                    abs(fileResolutions - autoRes) == min(
                        abs(fileResolutions - autoRes)
                    )
                )]
            }
        }

        return(as.integer(autoRes))
    }

    ## Define a function to parse chromosome/region for Straw
    parse_region <- function(chrom, chromstart, chromend, assembly) {
        strawChrom <- chrom

        if (is.null(chromstart) & is.null(chromend)) {
            regionStraw <- strawChrom
        } else {

            ## Keep chromstart and chromend without scientific notation
            ## for processing with Straw

            chromstart <- format(chromstart, scientific = FALSE)
            chromend <- format(chromend, scientific = FALSE)
            regionStraw <- paste(strawChrom, chromstart, chromend, sep = ":")
        }

        return(regionStraw)
    }

    ## Define a function to reorder chromsomes to put "chrom" input in col1
    orderChroms <- function(hic, chrom, altchrom, assembly) {
        
        chrom <- gsub("chr", "", chrom)
        altchrom <- gsub("chr", "", altchrom)
        
        if (!"X" %in% chrom & !"Y" %in% chrom) {
            chrom <- utils::type.convert(chrom, as.is = TRUE)
        }

        if (!"X" %in% altchrom & !"Y" %in% altchrom) {
            altchrom <- utils::type.convert(altchrom, as.is = TRUE)
        }

        ## CASE 1: two numbers
        if (all(is(chrom, "numeric"), is(altchrom, "numeric"))) {
            if (chrom > altchrom) {
                hic <- hic[, c("y", "x", "counts")]
            }
        } else if (any(is(chrom, "numeric"), is(altchrom, "numeric"))) {
            ## CASE 2: number and X/Y
            if (is(altchrom, "numeric")) {
                hic <- hic[, c("y", "x", "counts")]
            }
        } else {
            ## CASE 3: X and Y
            if ("Y" %in% chrom) {
                hic <- hic[, c("y", "x", "counts")]
            }
        }

        return(hic)
    }

    ## Define a function to rename columns
    rename_columns <- function(upper, chrom, altchrom) {
        if (is.null(altchrom)) {
            colnames(upper) <- c(paste0(chrom, "_A"), 
                            paste0(chrom, "_B"), "counts")
        } else {
            colnames(upper) <- c(chrom, altchrom, "counts")
        }

        return(upper)
    }

    # =========================================================================
    # PARSE PARAMETERS
    # =========================================================================

    rhic <- parseParams(params = params, 
                        defaultArgs = formals(eval(match.call()[[1]])),
                        declaredArgs = lapply(match.call()[-1], 
                                            eval.parent, n = 2),
                        class = "rhic")
    
    if (is.null(rhic$file)) stop("argument \"file\" is missing, ",
                                    "with no default.", call. = FALSE)
    if (is.null(rhic$chrom)) stop("argument \"chrom\" is missing, ",
                                    "with no default.", call. = FALSE)

    # =========================================================================
    # PARSE ASSEMBLY
    # =========================================================================

    rhic$assembly <- parseAssembly(assembly = rhic$assembly)

    # =========================================================================
    # CATCH ERRORS
    # =========================================================================

    errorcheck_readHic(
        hic = rhic$file, chrom = rhic$chrom,
        chromstart = rhic$chromstart,
        chromend = rhic$chromend, zrange = rhic$zrange,
        altchrom = rhic$altchrom,
        altchromstart = rhic$altchromstart,
        altchromend = rhic$altchromend, norm = rhic$norm,
        res_scale = rhic$res_scale,
        assembly = rhic$assembly$Genome
    )

    # =========================================================================
    # SET PARAMETERS
    # =========================================================================

    parse_chromstart <- rhic$chromstart
    parse_chromend <- rhic$chromend
    parse_altchromstart <- rhic$altchromstart
    parse_altchromend <- rhic$altchromend


    ## For off diagonal plotting, grabbing whole symmetric region
    if (!is.null(rhic$altchrom)) {
        if (rhic$chrom == rhic$altchrom) {
            parse_chromstart <- min(rhic$chromstart, rhic$altchromstart)
            parse_chromend <- max(rhic$chromend, rhic$altchromend)
        }
    }

    # =========================================================================
    # PARSE REGIONS
    # =========================================================================

    chromRegion <- parse_region(
        chrom = rhic$chrom,
        chromstart = parse_chromstart,
        chromend = parse_chromend,
        assembly = rhic$assembly$Genome
    )

    if (is.null(rhic$altchrom)) {
        altchromRegion <- chromRegion
    } else {
        if (rhic$chrom == rhic$altchrom) {
            altchromRegion <- chromRegion
        } else {
            altchromRegion <- parse_region(
                chrom = rhic$altchrom,
                chromstart = parse_altchromstart,
                chromend = parse_altchromend,
                assembly = rhic$assembly$Genome
            )
        }
    }

    # =========================================================================
    # ADJUST RESOLUTION
    # =========================================================================

    if (rhic$resolution == "auto") {
        rhic$resolution <- auto_resolution(
            file = rhic$file,
            chromstart = rhic$chromstart,
            chromend = rhic$chromend
        )
        rhic$res_scale <- "BP"
    }

    # =========================================================================
    # EXTRACT SPARSE UPPER TRIANGULAR USING STRAW
    # =========================================================================

    errorFunction <- function(c) {
        upper <- data.frame(matrix(nrow = 0, ncol = 3))
        colnames(upper) <- c("x", "y", "counts")
        return(upper)
    }

    log <- FALSE
    if (rhic$matrix == "logoe") {
        rhic$matrix <- "oe"
        log <- TRUE
    }
    
    upper <-
        tryCatch(strawr::straw(
            norm = rhic$norm,
            fname = normalizePath(rhic$file),
            chr1loc = toString(chromRegion),
            chr2loc = toString(altchromRegion),
            unit = rhic$res_scale,
            binsize = rhic$resolution,
            matrix = rhic$matrix
        ),
        error = errorFunction
        )

    if (log == TRUE) {
        upper[, "counts"] <- log2(upper[, "counts"])
    }


    # =========================================================================
    # REORDER COLUMNS BASED ON CHROM/ALTCHROM INPUT
    # =========================================================================

    if (!is.null(rhic$altchrom)) {
        upper <- orderChroms(
            hic = upper, chrom = rhic$chrom,
            altchrom = rhic$altchrom,
            assembly = rhic$assembly$Genome
        )
        colnames(upper) <- c("x", "y", "counts")
    }

    # =========================================================================
    # SCALE DATA WITH ZRANGE
    # =========================================================================

    scaled_data <- scale_data(upper = upper, zrange = rhic$zrange)

    # =========================================================================
    # FORMAT DATA IN PROPER ORDER AND WITH LABELS
    # =========================================================================

    renamed_data <- rename_columns(
        upper = scaled_data,
        chrom = rhic$chrom,
        altchrom = rhic$altchrom
    )

    # =========================================================================
    # REMOVE NAN VALUES
    # =========================================================================

    renamed_data <- na.omit(renamed_data)

    # =========================================================================
    # RETURN DATAFRAME
    # =========================================================================
    if (nrow(renamed_data) == 0) {
        warning("No data found in region. Suggestions: check that ",
                "chromosome names match genome assembly; ",
                "check region; check available resolutions ",
                "with `strawr::readHicBpResolutions()`.", call. = FALSE)
    } else {
        if (!rhic$quiet) {
            message(
                "Read in hic file with ",
                rhic$norm, " normalization at ",
                rhic$resolution, " ", rhic$res_scale,
                " resolution."
            )
        }
    }
    return(renamed_data)
}
