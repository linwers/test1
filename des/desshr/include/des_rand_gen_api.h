/* Copyright 2004 The MathWorks, Inc. */

/*#include "dsprandsrc64bit_rt.h"*/
#include "des_rand_util.h"

/* the sizes of state vectors for DSP uniform/normal random number generators */
#define MWDSP_UNIF_STATE_VECTOR_SIZE    35
#define MWDSP_NORM_STATE_VECTOR_SIZE    2

/* Distribution list
 * Uniform
 * Normal
 * Exponential
 * Weibull
 * Lognormal
 * Gamma
 * Arbitrary Continouous
 * Beta
 * Log-logistic
 * Bernoulli
 * Binomial
 * Poisson
 * Discrete uniform
 * Arbitrary Discrete 
 * Geometric
 * Triangular 
 */

/* generic structure containing parameter information and state vector(s) */

#include "des_rand_gen_defs.h"

/* parameter structure for uniform distribution */
typedef struct
{
    real64_T *min; /* minimum */
    real64_T *max; /* maximum */
} des_rng_param_unif;

/* parameter structure for exponential distribution */
typedef struct
{
    real64_T *mean; /* mean */
} des_rng_param_exp;

/* parameter structure for normal distribution */
typedef struct
{
    real64_T *mean;  /* mean */
    real64_T *std;   /* standard deviation */
} des_rng_param_norm;

/* parameter structure for Weibull distribution */
typedef struct
{
    real64_T *location;  /* location */
    real64_T *scale;   /* scale */
    real64_T *shape;    /* shape */
    real64_T *_shapeInv; /* temp variable storing 1/shape to speed up calculation */
} des_rng_param_wbl;

/* parameter structure for lognormal distribution */
typedef struct
{
    real64_T *location;  /* location */
    real64_T *scale;   /* scale */
    real64_T *shape;    /* shape */
} des_rng_param_logn;


/* parameter structure for Bernoulli distribution */
typedef struct
{
    real64_T *p1; /* probability for the output to be 1 */
} des_rng_param_bern;

/* parameter structure for binomial distribution */
typedef struct
{
    real64_T *pSuccess; /* probability for single trial to be successful */
    real64_T *numTrial; /* number of trials */
} des_rng_param_bino;

/* parameter structure for geometric distribution */
typedef struct
{
    real64_T *pSuccess; /* probability for single trial to be successful */
    real64_T *_invLog; /* temp variable storing 1.0/log(1-pSuccess) to speed 
                        * up calculation
                        */
} des_rng_param_geo;

/* parameter structure for discrete uniform distribution */
typedef struct
{
    real64_T *min; /* minimum */
    real64_T *max; /* maximum */
    real64_T *numValue; /* number of possible values for the discrete 
                         * uniform distribution (including min and max)
                         */
    real64_T *_interval; /* temp variable storing interval 
                          * = (max - min) / (Value - 1) 
                          */
} des_rng_param_unid;

/* parameter structure for arbitrary discrete distribution */
typedef struct
{
    real64_T *value;    /* value vector for the random variable */
    real64_T *prob;     /* probability vector for the random variable */    
    uint32_T numValue;  /* number of possible values; it should be equal to the
                         * number of elements in the value or probability 
                         * vector and be greater than 0
                         */    
    real64_T *_cdf;      /* temp variable cdf that stores cdf values; its width
                          * should be one greater than the width of value or
                          * probability vector so that it can contain a 0 for 
                          * the starting 0
                          */
} des_rng_param_disc;


/* parameter structure for gamma distribution */
typedef struct
{
    real64_T *location;  /* location */
    real64_T *scale;     /* scale */
    real64_T *shape;  /* shape */
    real64_T *tempVar;  /* two-element array to store temp variables */
} des_rng_param_gam;

/* parameter structure for log-logistic distribution */

typedef struct
{
    real64_T *scale;  /* scale for logistic distribution */
    real64_T *location; /* location for logistic distribution */
    real64_T *_expLoc; /* temp variable to store exp(location) */
} des_rng_param_logl;

/* parameter structure for Poisson distribution */
typedef struct
{
    real64_T *mean;  /* mean */
} des_rng_param_poiss;


/* parameter structure for beta distribution */
typedef struct
{
    real64_T *min; /* minimum */
    real64_T *max; /* maximum */
    real64_T *shape1; /* shape parameter a */ 
    real64_T *shape2; /* shape parameter b */
    real64_T *tempVar; /* 4-element array to store temp variables */
} des_rng_param_beta;


/* parameter structure for arbitrary continuous distribution */
typedef struct
{
    real64_T *value; /* value vector */
    real64_T *cdf; /* cdf vector */
    uint32_T numValue; /* number of values in the value or cdf vectors; this API
                        * requires at least 2 values 
                        */
} des_rng_param_cont;


/* parameter structure for triangular distribution */
typedef struct
{
    real64_T *min; /* minimum */
    real64_T *max; /* maximum */
    real64_T *mode; /* mode for the triangular distribution */
} des_rng_param_tri;


/* constants used by DSP random number generator to generate uniform 
 * distribution between 0 and 1 (both excluded) so that inverse transform
 * can be performed later to derive other distributions
 */
static const real64_T unifMin = 0.0, unifMax = 1.0;



/********************************** APIs *******************************/

/* uniform distribution */
/* function for parameter checking */
char * des_rng_chk_param_unif (void *p); 
/* function for parameter structure initialization */
void des_rng_set_param_unif (void *pParam, /* parameter structure */
                             real64_T *min, /* minimum */
                             real64_T *max); /* maximum */
/* function for state vector initialization */
void des_rng_svec_init_unif(uint32_T *seed, des_rng_param *p); 
/* random number generation */
void des_rng_rand_gen_unif (real64_T *u, des_rng_param *p); 


/* exponential distribution */
/* function for parameter checking */
char * des_rng_chk_param_exp (void *p); 
/* function for parameter structure initialization */
void des_rng_set_param_exp (void *pParam, /* parameter structure */
                            real64_T *mean); /* mean */
/* function for state vector initialization */
void des_rng_svec_init_exp(uint32_T *seed, des_rng_param *p); 
/* random number generation */
void des_rng_rand_gen_exp (real64_T *u, des_rng_param *p); 


/* normal distribution */
/* function for parameter checking */
char * des_rng_chk_param_norm (void *p); 
/* function for parameter structure initialization */
void des_rng_set_param_norm (void *pParam, /* parameter structure */
                             real64_T *mean, /* mean */
                             real64_T *std); /* standard deviation */
/* function for state vector initialization */
void des_rng_svec_init_norm (uint32_T *seed, des_rng_param *p); 
/* random number generation */
void des_rng_rand_gen_norm (real64_T *u, des_rng_param *p); 


/* Weibull distribution */
/* function for parameter checking */
char * des_rng_chk_param_wbl(void *p); 
/* function for parameter structure initialization; if temp variable
 * shapeInv is provided, calculate the value from the parameter setting and 
 * store it in shapeInv
 */
void des_rng_set_param_wbl (void *pParam, /* parameter structure */
                            real64_T *location, /* location */
                            real64_T *scale, /* scale */
                            real64_T *shape, /* shape */
                            real64_T *shapeInv); /* temp variable */
/* function for state vector initialization */
void des_rng_svec_init_wbl (uint32_T *seed, des_rng_param *p); 
/* random number generation */
void des_rng_rand_gen_wbl (real64_T *u, des_rng_param *p); 


/* lognormal distribution */
/* function for parameter checking */
char * des_rng_chk_param_logn(void *p); 
/* function for parameter structure initialization */
void des_rng_set_param_logn (void *pParam, /* parameter structure */
                            real64_T *location, /* location */
                            real64_T *scale, /* scale */
                            real64_T *shape); /* shape */
/* function for state vector initialization */
void des_rng_svec_init_logn (uint32_T *seed, des_rng_param *p); 
/* random number generation */
void des_rng_rand_gen_logn (real64_T *u, des_rng_param *p); 


/* Bernoulli distribution */
char * des_rng_chk_param_bern(void *p); 
/* function for parameter structure initialization */
void des_rng_set_param_bern (void *p, 
                             real64_T *p1); /* probability for the output to be 1 */
/* function for state vector initialization */
void des_rng_svec_init_bern (uint32_T *seed, des_rng_param *p); 
/* random number generation */
void des_rng_rand_gen_bern (real64_T *u, des_rng_param *p); 


/* Binomial distribution */
char * des_rng_chk_param_bino(void *p); 
/* function for parameter structure initialization */
void des_rng_set_param_bino (void *p, 
                             real64_T *pSuccess, /* probability of success 
                                                  * in a single trial 
                                                  */
                             real64_T *numTrial); /* number of trials */
/* function for state vector initialization */
void des_rng_svec_init_bino (uint32_T *seed, des_rng_param *p); 
/* random number generation */
void des_rng_rand_gen_bino (real64_T *u, des_rng_param *p); 


/* geometric distribution */
char * des_rng_chk_param_geo (void *p); 
/* function for parameter structure initialization */
void des_rng_set_param_geo (void *p, /* parameter structure */
                            real64_T *pSuccess, /* probability of success in 
                                                 * a single trial 
                                                 */
                            real64_T *invLog);
/* function for state vector initialization */
void des_rng_svec_init_geo (uint32_T *seed, des_rng_param *p); 
/* random number generation 
 * NOTE: The geometric distribution represents the probability of getting 
 * n failures before the first success, where the probability of success in 
 * a single try is pSuccess. In other words, the success is NOT counted in 
 * final output. For example if a success follows three consecutive failures,
 * the output is 3, but not 4.
 */
void des_rng_rand_gen_geo (real64_T *u, des_rng_param *p); 


/* discrete uniform distribution */
char * des_rng_chk_param_unid (void *p); 
/* function for parameter structure initialization */
void des_rng_set_param_unid (void *pParam, /* parameter structure */
                             real64_T *min, /* minimum */
                             real64_T *max, /* maximum */
                             real64_T *numValue,/* number of possible values 
                                                 * (including min and max)
                                                 */
                             real64_T *intervalSize); /* temp variable */
/* function for state vector initialization */
void des_rng_svec_init_unid (uint32_T *seed, des_rng_param *p); 
/* random number generation */
void des_rng_rand_gen_unid (real64_T *u, des_rng_param *p); 


/* arbitrary discrete distribution */
char * des_rng_chk_param_disc (void *p); 
/* function for parameter structure initialization: for SINGLE CHANNEL ONLY */
void des_rng_set_param_disc_schan(void *p, 
                                  real64_T *value, /* value vector */
                                  real64_T *prob, /* probability vector (with the 
                                                   * same width as the value vector
                                                   */
                                  uint32_T numValue, /* number of possible values*/
                                  real64_T *cdf);   /* temp variable storing cdf */
/* function for state vector initialization */
void des_rng_svec_init_disc (uint32_T *seed, des_rng_param *p); 
/* random number generation */
void des_rng_rand_gen_disc (real64_T *u, des_rng_param *p); 


/* gamma distribution */
char * des_rng_chk_param_gam (void *pParam); 
/* function for parameter structure initialization */
void des_rng_set_param_gam (void *p, /* parameter structure */
                            real64_T *location, /* location */
                            real64_T *scale, /* scale */
                            real64_T *shape, /* shape */
                            real64_T *tempVar); /* temp variable */
/* function for state vector initialization */
void des_rng_svec_init_gam (uint32_T *seed, des_rng_param *p); 
/* random number generation for standard gamma distribution */
void des_rng_set_param_gam_temp_var_init(real64_T *shape, real64_T *tempVar);
void des_rng_rand_gen_gam_std(real64_T *u, /*output*/
                                        real64_T *shape, /* shape */
                                        real64_T *unifSVec, /* uniform state vector */
                                        uint32_T *normSVec, /* normal state vector */
                                        real64_T *tempVar, /* 2-element temp variables array*/
                                        void(*err_func)(const char *));/* pointer to the function that prints error message */
/* random number generation */
void des_rng_rand_gen_gam (real64_T *u, des_rng_param *p); 


/* log-logistic distribution */
char * des_rng_chk_param_logl (void *pParam); 
/* function for parameter structure initialization */
void des_rng_set_param_logl (void *pParam, /* parameter structure */
                             real64_T *location, /* location */
                             real64_T *scale, /* scale */ 
                             real64_T *expLoc); /* temp variable */
/* function for state vector initialization */
void des_rng_svec_init_logl (uint32_T *seed, des_rng_param *p); 
/* random number generation */
void des_rng_rand_gen_logl (real64_T *u, des_rng_param *p); 


/* Poisson distribution */
char * des_rng_chk_param_poiss (void *pParam); 
/* function for parameter structure initialization */
void des_rng_set_param_poiss (void *p, /* parameter structure */
                             real64_T *mean); /* mean */                             
/* function for state vector initialization */
void des_rng_svec_init_poiss (uint32_T *seed, des_rng_param *p); 
/* Knuth's recommendation on Poisson distribution */
real64_T des_rng_rand_gen_poiss_scalar(real64_T mean, real64_T *unifSVec, uint32_T *normSVec, void (*errFunc) (const char* msg));
/* random number generation */
void des_rng_rand_gen_poiss (real64_T *u, des_rng_param *p); 


/* beta distribution */
char * des_rng_chk_param_beta (void *pParam); 
/* function for parameter structure initialization */
void des_rng_set_param_beta (void *p, /* parameter structure */
                             real64_T *min, /* minimum */
                             real64_T *max, /* maximum */
                             real64_T *shape1, 
                             real64_T *shape2, /* two shape parameters */
                             real64_T *tempVar); /* 4-element temp variable array */
/* function for state vector initialization */
void des_rng_svec_init_beta (uint32_T *seed, des_rng_param *p); 
/* random number generation */
void des_rng_rand_gen_beta (real64_T *u, des_rng_param *p); 


/* arbitrary continuous distribution */
char * des_rng_chk_param_cont (void *pParam); 
/* function for parameter structure initialization: for SINGLE CHANNEL only */
void des_rng_set_param_cont_schan (void *p, /* parameter structure */
                                   real64_T *value, /* value vector */
                                   real64_T *cdf, /* cdf vector (with the same 
                                                   * width as the value vector 
                                                   */
                             uint32_T numValue); /* number of elements in the 
                                                  * value vector 
                                                  */
/* function for state vector initialization */
void des_rng_svec_init_cont (uint32_T *seed, des_rng_param *p); 
/* random number generation */
void des_rng_rand_gen_cont (real64_T *u, des_rng_param *p); 

/* triangular distribution */
char * des_rng_chk_param_tri(void *pParam); 
/* function for parameter structure initialization: for SINGLE CHANNEL only */
void des_rng_set_param_tri(void *p, /* parameter structure */
                                   real64_T *min, /* minimum */
                                   real64_T *max, /* maxmum */
                                   real64_T *mode); /* mode */
/* function for state vector initialization */
void des_rng_svec_init_tri(uint32_T *seed, des_rng_param *p); 
/* random number generation */
void des_rng_rand_gen_tri(real64_T *u, des_rng_param *p); 

