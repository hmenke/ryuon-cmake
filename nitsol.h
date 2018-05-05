#ifndef NITSOL_FORTRAN_H
#define NITSOL_FORTRAN_H

typedef struct {
    double avrate, fcurnrm;
    int instep, newstep, krystat;
} nitinfo;

extern nitinfo nitinfo_;

typedef struct {
    int iplvl, ipunit;
} nitprint;

extern nitprint nitprint_;

typedef struct {
    double choice1_exp, choice2_exp, choice2_coef;
    double eta_cutoff, etamax;
    double thmin, thmax, etafixed;
} nitparam;

extern nitparam nitparam_;

#endif /* NITSOL_FORTRAN_H */
