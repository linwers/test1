/* Copyright 2004-2006 The MathWorks, Inc. */


/** des_rand_util.h - Utility file for DES RNG functions. 
*   $Date   $Revision
*/


#define DESRNG_INV_MIN_MAX     "The minimum must be less than or equal to the maximum"                                        
#define DESRNG_INV_MIN_MAX2    "The minimum must be less than the maximum"                                        
#define DESRNG_INV_SEED        "The seed must be a nonnegative integer"                                            
#define DESRNG_INV_MEAN        "The mean must be a positive real number"                                                      
#define DESRNG_INV_STD         "The standard deviation must be a positive real number"                                        
#define DESRNG_INV_SCALE       "The scale parameter must be a positive real number"
#define DESRNG_INV_SHAPE       "The shape parameter must be a positive real number"
#define DESRNG_INV_SIGMA       "The Sigma parameter must be a positive real number"
#define DESRNG_INV_PROB        "A probability must be a real number less than or equal to 1, and greater than or equal to 0" 
#define DESRNG_INV_PROB2       "A probability in arbitrary discrete distribution must be a real number greater than 0 and less than or equal to 1" 
#define DESRNG_INV_NUM_TRIAL   "The number of trials must be a positive integer"                                       
#define DESRNG_INV_NUM_VEC     "The number of values for arbitrary discrete distribution must be a positive integer"
#define DESRNG_INV_VALUE       "The values for an arbitrary (continuous or discrete) distribution must be in an ascending order"
#define DESRNG_INV_PROB_DIST   "The sum of probabilities for an arbitrary distribution must add up to 1"                                               
#define DESRNG_INV_NUM_VALUE   "The number of possible values for discrete uniform distribution must be greater than 1" 
#define DESRNG_INV_NUM_VALUE2  "An arbitrary continuous distribution must have at least two values"
#define DESRNG_INV_NUM_VALUE3  "The number of possible values for discrete uniform distribution must be an integer" 
#define DESRNG_INV_CDF2        "The values of a cumulative probability function must be in an ascending order"
#define DESRNG_INV_CDF3        "The first value of a cumulative probability function must be 0"
#define DESRNG_INV_CDF4        "The last value of a cumulative probability function must be 1"
#define DESRNG_INV_MODE         "The mode should be greater than the minimum and less than the maximum for triangular distribution"
#define DESRNG_INV_SCALAR       "Input parameters must be valid scalars"
#define DESRNG_INV_VECTOR       "Input parameters must be valid vectors"

#define DESRNG_NO_MEMORY       "Memory allocation failure"                                                      
#define DESRNG_UNKNOWN_ERROR    "Unknown error"                                                                  

