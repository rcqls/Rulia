#include <stdio.h>
#include <string.h>

//#include <julia.h>
//#include "julia.h"
#include "julia.h"
#include <Rdefines.h>
#include <R_ext/PrtUtil.h>

// It seems that this fails on win32 "fd_set" missing!
// #ifndef Win32
// #include <R_ext/eventloop.h>
// #endif

#define preserved

// JULIA_DEFINE_FAST_TLS => ISSUE on docker linux relocation R_X86_64_TPOFF32 against `jl_pgcstack_localexec'
static int Rulia_julia_running=0;
static jl_module_t* jl_R_module;
SEXP jlvalue(jl_value_t* jlvalue);

#ifdef preserved
static jl_value_t* preserved_refs;
static jl_datatype_t* reft;
// static jl_function_t* setindex;
// static jl_function_t* delete;
// static jl_function_t* getfield;

void jl_init_preserved_refs() {
  preserved_refs = jl_eval_string("preserved_refs = IdDict()");
  reft = (jl_datatype_t*)jl_eval_string("Base.RefValue{Any}");
  // setindex = jl_get_function(jl_base_module, "setindex!");
  // delete = jl_get_function(jl_base_module, "delete!");
  // getfield = jl_get_function(jl_base_module, "getfield");
}

void jl_add_preserved_ref(jl_value_t *ref) {
  jl_function_t* setindex = jl_get_function(jl_base_module, "setindex!");
  jl_call3(setindex, preserved_refs, ref, ref);
}

void jl_rm_preserved_ref(jl_value_t *ref) {
  jl_function_t* delete = jl_get_function(jl_base_module, "delete!");
  jl_call2(delete, preserved_refs, ref);
}

jl_value_t* get_preserved_jlvalue_from_R_ExternalPtrAddr(SEXP ans) {
  jl_value_t *res=NULL, *ref=NULL;
  jl_function_t* getfield = jl_get_function(jl_base_module, "getfield");
  JL_GC_PUSH2(&res,&ref);
  ref = (jl_value_t*)R_ExternalPtrAddr(ans);
  res = (jl_value_t*)jl_call2(getfield, ref,(jl_value_t*)jl_symbol("x"));
  JL_GC_POP();
  return res;
}

#else

jl_value_t* get_preserved_jlvalue_from_R_ExternalPtrAddr(SEXP ans) {
  jl_value_t *res=NULL;
  JL_GC_PUSH1(&res);
  res = (jl_value_t*)R_ExternalPtrAddr(ans);
  JL_GC_POP();
  return res;
}

#endif 

SEXP Rulia_init(SEXP args)
{
  // char *julia_home_dir;

  if(!Rulia_julia_running) {
    // if(!isValidString(CADR(args)))
    //  error("invalid argument");
    // julia_home_dir=(char*)CHAR(STRING_ELT(CADR(args), 0));
    // Rprintf("julia_home_dir=%s\n",julia_home_dir);
    // jl_init(julia_home_dir);
    jl_init();
    Rulia_julia_running=1;
    //printf("julia initialized!!!\n");
#ifdef preserved
    jl_init_preserved_refs();
#endif
  }
  return R_NilValue;
}

void Rulia_exit()
{
  if(Rulia_julia_running) {
    jl_atexit_hook(0);
    Rulia_julia_running = 0;
    printf("julia stopped!!!\n");
  }
}

SEXP Rulia_running(void) {
  SEXP ans;

  PROTECT(ans=allocVector(LGLSXP,1));
  LOGICAL(ans)[0]=Rulia_julia_running;
  UNPROTECT(1);
  return(ans);
}

SEXP jl_value_type(jl_value_t *res) {
  char *resTy,*aryTy;
  SEXP resR;

  if(res!=NULL) { //=> get a result
    resTy=(char*)jl_typeof_str(res);
    PROTECT(resR=NEW_CHARACTER(1));
    CHARACTER_POINTER(resR)[0]=mkChar(resTy);
    UNPROTECT(1);
    return resR;
  } return R_NilValue;
}

int Rulia_isa(jl_value_t *jlv, char* typ) {
  jl_value_t *jl_typ=NULL;
  int res;

  JL_GC_PUSH1(&jl_typ);
  jl_typ = jl_eval_string(typ);
  res = jl_isa(jlv,jl_typ);
  JL_GC_POP();
  return res;
}

//Maybe try to use cpp stuff to get the output inside julia system (ccall,cgen and cgutils)
//-| TODO: after adding in the jlapi.c jl_is_<C_type> functions replace the strcmp!
SEXP jl_value_to_SEXP(jl_value_t *res) {
  size_t i=0,nd,d;
  SEXP resR;
  SEXP nmsR;
  SEXPTYPE aryTyR;
  jl_value_t *tmp;
  jl_function_t *func, *len, *func2, *collect;
  char *resTy, *aryTy, *aryTy2;

  if(res!=NULL) { //=> get a result
    resTy=(char*)jl_typeof_str(res);
    //printf("typeof=%s\n",resTy);
    if(strcmp(resTy,"Bool")==0) // Need to be before Integer
    //if(jl_is_bool(res))
    {
      PROTECT(resR=NEW_LOGICAL(1));
      LOGICAL(resR)[0]=(jl_unbox_bool(res)  ? TRUE : FALSE);
      UNPROTECT(1);
      return resR;
    }
    else
    if(Rulia_isa(res,"Integer")) 
    // if(strcmp(jl_typeof_str(res),"Int64")==0 || strcmp(jl_typeof_str(res),"Int32")==0 || strcmp(jl_typeof_str(res),"UInt64")==0 || strcmp(jl_typeof_str(res),"UInt32")==0)
    //if(jl_is_long(res)) //does not work because of DLLEXPORT
    {
      //printf("elt=%d\n",jl_unbox_long(res));
      PROTECT(resR=NEW_INTEGER(1));
      INTEGER_POINTER(resR)[0]=jl_unbox_long(res);
      UNPROTECT(1);
      return resR;
    }
    else
    if(strcmp(resTy,"Float64")==0)
    //if(jl_is_float64(res))
    {
      PROTECT(resR=NEW_NUMERIC(1));
      NUMERIC_POINTER(resR)[0]=jl_unbox_float64(res);
      UNPROTECT(1);
      return resR;
    }
    else
    if(strcmp(resTy,"Float32")==0)
    //if(jl_is_float64(res))
    {

      PROTECT(resR=NEW_NUMERIC(1));
      NUMERIC_POINTER(resR)[0]=jl_unbox_float32(res);
      UNPROTECT(1);
      return resR;
    }
    else
    if(strcmp(resTy,"DataType")==0)
    //if(jl_is_bool(res))
    {
      PROTECT(resR=NEW_CHARACTER(1));
      CHARACTER_POINTER(resR)[0]=mkChar(jl_typename_str(res));
      UNPROTECT(1);
      return resR;
    }
    else
    if(strcmp(resTy,"Nothing")==0)
    //if(jl_is_bool(res))
    {
      return R_NilValue;
    }
    else
    if(strcmp(resTy,"Complex")==0)
    //if(jl_is_bool(res))
    {

      tmp=(jl_value_t*)jl_get_field(res, "re");
      PROTECT(resR=NEW_COMPLEX(1));
      if(strcmp(jl_typeof_str(tmp),"Float64")==0) {
        COMPLEX(resR)[0].r=jl_unbox_float64(tmp);
        COMPLEX(resR)[0].i=jl_unbox_float64(jl_get_field(res, "im"));
      } else if(strcmp(jl_typeof_str(tmp),"Int64")==0) {
        COMPLEX(resR)[0].r=jl_unbox_long(tmp);
        COMPLEX(resR)[0].i=jl_unbox_long(jl_get_field(res, "im"));
      }
      UNPROTECT(1);
      return resR;
    }
    else
    if(strcmp(resTy,"Regex")==0)
    //if(jl_is_bool(res))
    {
      // call=(jl_function_t*)jl_get_global(jl_base_module, jl_symbol("show"));
      // printf("ici\n");
      // if (call) tmp=jl_call1(call,res);
      // else printf("call failed!\n");
      // printf("ici\n");
      // resR = jl_value_to_VALUE(jl_get_field(res, "pattern"));
      // return resR;
    }
    else
    if(strcmp(resTy,"String")==0)
    {
      PROTECT(resR=NEW_CHARACTER(1));
      CHARACTER_POINTER(resR)[0]=mkChar(jl_string_ptr(res));
      UNPROTECT(1);
      return resR;
    }
    else
    if(strcmp(resTy,"Symbol")==0 )
    {
       PROTECT(resR=NEW_CHARACTER(1));
      CHARACTER_POINTER(resR)[0]=mkChar(jl_symbol_name((jl_sym_t *)res));
      UNPROTECT(1);
      return resR;
    }
    else
    if(strcmp(jl_typeof_str(res),"Tuple")==0)
    //if(jl_is_array(res))
    {
      d=jl_nfields(res); //BEFORE 0.3: d=jl_tuple_len(res);
      PROTECT(resR=allocVector(VECSXP,d));
      for(i=0;i<d;i++) {
        //BEFORE 0.3: SET_ELEMENT(resR,i,jl_value_to_SEXP(jl_tupleref(res,i)));
        SET_ELEMENT(resR,i,jl_value_to_SEXP(jl_fieldref(res,i)));
      }
      UNPROTECT(1);
      return resR;
    }
    else
    if(strcmp(jl_typeof_str(res),"NamedTuple")==0)
    //if(jl_is_array(res))
    {
      d=jl_nfields(res); //BEFORE 0.3: d=jl_tuple_len(res);
      func = jl_get_function(jl_base_module, "keys");
      jl_value_t *keys = jl_call1(func, res);
      PROTECT(nmsR = allocVector(STRSXP, d));
      PROTECT(resR=allocVector(VECSXP,d));
      for(i=0;i<d;i++) {
        //BEFORE 0.3: SET_ELEMENT(resR,i,jl_value_to_SEXP(jl_tupleref(res,i)));
        SET_ELEMENT(resR,i,jl_value_to_SEXP(jl_fieldref(res,i)));
        SET_STRING_ELT(nmsR,i,mkChar(jl_symbol_name((jl_sym_t *)jl_fieldref(keys,i))));
      }
      setAttrib(resR, R_NamesSymbol, nmsR);
      UNPROTECT(1);
      UNPROTECT(1);
      
      return resR;
    }
    else
    if(strcmp(jl_typeof_str(res),"Dict")==0)
    //if(jl_is_array(res))
    {
      d=1; //jl_nfields(res); //BEFORE 0.3: d=jl_tuple_len(res);
      len = jl_get_function(jl_base_module, "length");
      jl_value_t *l = jl_call1(len, res);
      d = jl_unbox_long(l);
      func = jl_get_function(jl_base_module, "keys");
      func2 = jl_get_function(jl_base_module, "values");
      collect = jl_get_function(jl_base_module, "collect");
      jl_value_t *keys = NULL, *tmpkeys = NULL, *vals = NULL, *tmpvals = NULL;
      JL_GC_PUSH4(&keys,&tmpkeys, &vals, &tmpvals);
      tmpkeys = jl_call1(func, res);
      keys = jl_call1(collect, tmpkeys);
      tmpvals = jl_call1(func2, res);
      vals = jl_call1(collect, tmpvals);
      
      PROTECT(nmsR = allocVector(STRSXP, d));
      PROTECT(resR=allocVector(VECSXP,d));
      for(i=0;i<d;i++) {
        //BEFORE 0.3: SET_ELEMENT(resR,i,jl_value_to_SEXP(jl_tupleref(res,i)));
        //printf("i=%zu/%zu\n",i,d);
        SET_STRING_ELT(nmsR,i,mkChar(jl_symbol_name((jl_sym_t *)jl_arrayref((jl_array_t *)keys,i))));
        SET_ELEMENT(resR,i,jl_value_to_SEXP(jl_arrayref((jl_array_t *)vals,i)));
      }
      setAttrib(resR, R_NamesSymbol, nmsR);
      UNPROTECT(1);
      UNPROTECT(1);
      JL_GC_POP();
      return resR;
    }
    else
    if(strcmp(resTy,"Array")==0)
    //if(jl_is_array(res))
    {
      nd = (int)jl_array_ndims(res);
      // Rprintf("array_ndims=%d\n",(int)nd);
      aryTy=(char*)jl_typename_str(jl_array_eltype(res));
      aryTy2=(char*)jl_typeof_str(jl_array_eltype(res));
      //Rprintf("type elt=%s,%s\n",aryTy,(char*)jl_typeof_str(jl_array_eltype(res)));
      if(strcmp(aryTy2,"DataType")!=0) return R_NilValue;
      if(strcmp(aryTy,"String")==0) aryTyR=STRSXP;
      else if(strcmp(aryTy,"Int64")==0 || strcmp(aryTy,"Int32")==0) aryTyR=INTSXP;
      else if(strcmp(aryTy,"Bool")==0) aryTyR=LGLSXP;
      else if(strcmp(aryTy,"Complex")==0) aryTyR=CPLXSXP;
      else if(strcmp(aryTy,"Float64")==0 || strcmp(aryTy,"Float32")==0) aryTyR=REALSXP;
      else aryTyR=VECSXP;
      //if(nd==1) {//Vector
        d = 1; for(int dim=0; dim < nd; dim++) d *= (int)jl_array_size(res, dim); //jl_array_size is defined in jlapi.c, weirdly jl_array_dim does not work here!
        // Rprintf("array_dim[1]=%d\n",(int)d);
        PROTECT(resR=allocVector(aryTyR,d));
        if(nd > 1) { //nmsR corresponds here to R_DimSymbol attribute
          PROTECT(nmsR = allocVector(INTSXP, nd));
          for(int dim=0; dim < nd; dim++) {
            INTEGER(nmsR)[dim] = (int)jl_array_size(res, dim);
          }
        }
        for(i=0;i<d;i++) {
          switch(aryTyR) {
            case STRSXP:
              SET_STRING_ELT(resR,i,mkChar(jl_string_ptr(jl_arrayref((jl_array_t *)res,i))));
              break;
            case INTSXP:
              INTEGER(resR)[i]=jl_unbox_long(jl_arrayref((jl_array_t *)res,i));
              break;
            case LGLSXP:
              LOGICAL(resR)[i]=(jl_unbox_bool(jl_arrayref((jl_array_t *)res,i)) ? TRUE : FALSE);
              break;
            case REALSXP:
              REAL(resR)[i]=jl_unbox_float64(jl_arrayref((jl_array_t *)res,i));
              break;
            case CPLXSXP:
              tmp=(jl_value_t*)jl_get_field(jl_arrayref((jl_array_t *)res,i), "re");
              if(strcmp(jl_typeof_str(tmp),"Float64")==0) {
                COMPLEX(resR)[i].r=jl_unbox_float64(tmp);
                COMPLEX(resR)[i].i=jl_unbox_float64(jl_get_field(jl_arrayref((jl_array_t *)res,i), "im"));
              } else if(strcmp(jl_typeof_str(tmp),"Int64")==0) {
                COMPLEX(resR)[i].r=jl_unbox_long(tmp);
                COMPLEX(resR)[i].i=jl_unbox_long(jl_get_field(jl_arrayref((jl_array_t *)res,i), "im"));
              }
              break;
            case VECSXP:
              SET_ELEMENT(resR,i,jl_value_to_SEXP(jl_arrayref((jl_array_t *)res,i)));
          }
        }
        if(nd > 1) {
          setAttrib(resR, R_DimSymbol, nmsR);
          UNPROTECT(1);
        }
        UNPROTECT(1);
        return resR;
      //}
    } else {
      resR = (SEXP)jlvalue(res);
      // PROTECT(resR=allocVector(STRSXP,1));
      // PROTECT(nmsR = allocVector(STRSXP, 2));
      // SET_STRING_ELT(resR,0,mkChar(resTy));
      // SET_STRING_ELT(nmsR,0,mkChar(resTy));
      // SET_STRING_ELT(nmsR,1, mkChar("jl_value"));
      // setAttrib(resR, R_ClassSymbol, nmsR);
      // UNPROTECT(1);
      // UNPROTECT(1);
      return resR;
    }
  }
  return R_NilValue;
}

/***************** EVAL **********************/
/*********/

jl_value_t* jl_eval2jl(SEXP args) {
  char *cmdString;
  jl_value_t *res;
  SEXP resR;

  cmdString=(char*)CHAR(STRING_ELT(CADR(args),0));
  // printf("exec: %s\n",cmdString);
  res=jl_eval_string(cmdString);
  if (jl_exception_occurred()) {
    // printf("%s \n", jl_typeof_str(jl_exception_occurred()));
    return (jl_value_t *)jl_exception_occurred(); //jl_eval_string("nothing");
  }
  JL_GC_PUSH1(&res);
  jl_set_global(jl_main_module, jl_symbol("Rulia_ANSWER"),res);
  JL_GC_POP();
  return res;
}

// USE toR instead
// SEXP Rulia_eval2R(SEXP args)
// {
//   jl_value_t *res=NULL;
//   SEXP resR;
//   JL_GC_PUSH1(&res);
//   res = jl_eval2jl(args);
  
//   resR=jl_value_to_SEXP(res);
//   if(res==NULL) {
//     if(resR != R_NilValue) resR=R_NilValue;
//     else  resR=R_NilValue;//newJLObj(res);
//   }
//   JL_GC_POP();
//   return resR;
// }

SEXP Rulia_run(SEXP args)
{
  char *cmdString;

  cmdString=(char*)CHAR(STRING_ELT(CADR(args),0));
  jl_eval_string(cmdString);
  if (jl_exception_occurred())
    printf("Julia Error: %s \n", jl_typeof_str(jl_exception_occurred()));
  return R_NilValue;
}

SEXP Rulia_run_with_exception(SEXP args)
{
  char *cmdString;

  cmdString=(char*)CHAR(STRING_ELT(CADR(args),0));
  jl_eval_string(cmdString);
  if (jl_exception_occurred())
    // printf("Julia Error: %s \n", jl_typeof_str(jl_exception_occurred()));
    return jlvalue(jl_exception_occurred()); //jl_eval_string("nothing");
  return R_NilValue;
}

/************ the converse **************/
jl_value_t* Vector_SEXP_to_jl_array(SEXP ans) {
  int n;
  //Rcomplex cpl;
  jl_datatype_t *datatype;
  jl_value_t *array_type, *elt;
  jl_array_t *x=NULL;
  int i;

  n=length(ans);
  // printf("typeof %d, isArray %d\n",TYPEOF(ans), isArray(ans));
  switch(TYPEOF(ans)) {
  case REALSXP:
    datatype = jl_float64_type;
    break;
  case INTSXP:
    datatype = jl_int64_type;
    break;
  case LGLSXP:
    datatype = jl_bool_type;
    break;
  case STRSXP:
    datatype = jl_string_type;
    break;
  }

 JL_GC_PUSH1(&x);
  array_type = jl_apply_array_type( (jl_value_t*)datatype, 1 );
  x          = jl_alloc_array_1d(array_type , n);


  switch(TYPEOF(ans)) {
  case REALSXP:
    // xData = (double*)jl_array_data(x);
    // for(size_t i=0; i<jl_array_len(x); i++) ((double*)xData)[i] = jl_box_float64(REAL(ans)[i]);
    for(i=0;i<n;i++) {
      elt=jl_box_float64(REAL(ans)[i]);
      jl_arrayset((jl_array_t*)x,elt,i);
      jl_gc_wb(x, elt);
    }
    break;
  case INTSXP:
    // xData = (int*)jl_array_data(x);
    // for(size_t i=0; i<jl_array_len(x); i++) ((int*)xData)[i] = jl_box_long(INTEGER(ans)[i]);
    for(i=0;i<n;i++) {
      elt=jl_box_long(INTEGER(ans)[i]);
      jl_arrayset((jl_array_t*)x,elt,i);
      jl_gc_wb(x, elt);
    }
    break;
  case LGLSXP:
    for(i=0;i<n;i++) {
      elt=jl_box_bool((INTEGER(ans)[i] ? 1 : 0));
      jl_arrayset((jl_array_t*)x,elt,i);
      jl_gc_wb(x, elt);
    }
    break;
  case STRSXP:
    for(i=0;i<n;i++) {
      elt=jl_cstr_to_string((char*)CHAR(STRING_ELT(ans,i)));
      jl_arrayset((jl_array_t*)x,elt,i);
      jl_gc_wb(x, elt);
    }
    break;
  }
  JL_GC_POP();

  return (jl_value_t*)x;
}

SEXP Rulia_VECSXP_to_jl_array_EXTPTRSXP(SEXP ans) {
  jl_value_t *res=NULL;
  SEXP resR;

  JL_GC_PUSH1(&res);
  res = Vector_SEXP_to_jl_array(ans);
  resR = jlvalue(res);
  JL_GC_POP();
  return resR;
}
/****************************/

SEXP Rulia_jl_symbol(SEXP ans) {
  jl_value_t* symb=NULL;
  char* symbol_name;
  SEXP resR;

  JL_GC_PUSH1(&symb);
  symbol_name=(char*)CHAR(STRING_ELT(CADR(ans),0));
  symb = (jl_value_t*)jl_symbol(symbol_name);
  resR = jlvalue(symb);
  JL_GC_POP();
  return resR;
}

/********/

SEXP Rulia_get_ans(void) {
  jl_value_t *res;

  res=jl_get_global(jl_main_module, jl_symbol("Rulia_ANSWER"));
  return jl_value_to_SEXP(res);
}

SEXP Rulia_set_global_variable(SEXP args) {
  char *varName;
  jl_value_t *res;

  varName=(char*)CHAR(STRING_ELT(CADR(args),0));
  res=(jl_value_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADDR(args));
  jl_set_global(jl_main_module, jl_symbol(varName),res);
  //jlapi_print_stdout();
  return R_NilValue;
}

static void jlvalueFinalizer(SEXP ptr) {
  jl_value_t *ref=NULL;
  JL_GC_PUSH1(&ref);
  ref = (jl_value_t*)R_ExternalPtrAddr(ptr);
  if(!ref) return;
#ifdef preserved
    jl_rm_preserved_ref(ref);
#endif
  JL_GC_POP();
  // printf("Finalized...\n");
  R_ClearExternalPtr(ptr); /* not really needed */
}

SEXP Rulia_finalizeExternalPtr(SEXP extptrlist) {
  int i, n;
  SEXP ptr;

  n = length(extptrlist);
  for(i = 0; i < n; i++) {
    ptr = (SEXP)VECTOR_ELT(extptrlist, i);
    jlvalueFinalizer(ptr);
  }
  return R_NilValue;

}
/************************************************/

//// R class jlvalue standing for jl_value_t External Pointer

SEXP jlvalue(jl_value_t* jlval) {
  SEXP ans, class;
  char *jltype;

#ifdef preserved
  jl_value_t *ref=NULL;

  JL_GC_PUSH2(&ref,&jlval);
  // Wrap `jlvalue` in `RefValue{Any}` and push to `preserved_refs` to protect it.
  ref = jl_new_struct(reft, jlval);
  jl_add_preserved_ref(ref);
  PROTECT(ans=(SEXP)R_MakeExternalPtr((void *)ref, R_NilValue, R_NilValue));
  JL_GC_POP();
 #else
  PROTECT(ans=(SEXP)R_MakeExternalPtr((void *)jlvalue, R_NilValue, R_NilValue));
 #endif
  R_RegisterCFinalizerEx(ans, jlvalueFinalizer, TRUE);
  PROTECT(class=allocVector(STRSXP,2));
  jltype=(char*)jl_typeof_str(jlval);
  // printf("jlvalue jltype -> %s\n", jltype);
  SET_STRING_ELT(class,0, mkChar(jltype));
  SET_STRING_ELT(class,1, mkChar("jlvalue"));
  SET_CLASS(ans,class);
  UNPROTECT(2);

  return ans;
}

SEXP Rulia_jlvalue_eval(SEXP args)
{
  SEXP resR;
  jl_value_t *res=NULL;

  JL_GC_PUSH1(&res);
  res = jl_eval2jl(args);
  resR = jlvalue(res);
  JL_GC_POP();
  return resR;
}

SEXP Rulia_jlvalue_call0(SEXP args) {
  char *meth;
  jl_value_t *res=NULL;
  jl_function_t *func;
  SEXP resR;

  JL_GC_PUSH2(&res,&func);
  meth = (char*)CHAR(STRING_ELT(CADR(args),0));
  func = jl_get_function(jl_main_module, meth);
  res = jl_call0(func);
  resR=(SEXP)jlvalue(res);
  JL_GC_POP();
  return resR;
}

SEXP Rulia_jlvalue_call1(SEXP args) {
  char *meth;
  jl_value_t *jlv=NULL, *res=NULL;
  jl_function_t *func=NULL;
  SEXP resR;

  meth = (char*)CHAR(STRING_ELT(CADR(args),0));
  JL_GC_PUSH3(&jlv,&func,&res);
  jlv=(jl_value_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADDR(args));
  func = jl_get_function(jl_main_module, meth);
  res = jl_call1(func, jlv);
  resR=(SEXP)jlvalue(res);
  JL_GC_POP();
  return resR;
}

SEXP Rulia_jlvalue_func_call1(SEXP args) {
  jl_value_t *jlv=NULL, *res=NULL;
  jl_function_t *func=NULL;
  SEXP resR;
  JL_GC_PUSH3(&jlv,&func,&res);
  func = (jl_function_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADR(args));
  jlv=(jl_value_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADDR(args));
  res = jl_call1(func, jlv);
  resR=(SEXP)jlvalue(res);
  JL_GC_POP();
  return resR;
}

SEXP Rulia_jlvalue_call2(SEXP args) {
  char *meth;
  jl_value_t *jlv = NULL, *res = NULL, *jlarg = NULL;
  jl_function_t *func=NULL;
  SEXP resR;

  meth = (char*)CHAR(STRING_ELT(CADR(args),0));
  JL_GC_PUSH4(&jlv,&res,&jlarg,&func);
  jlv=(jl_value_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADDR(args));
  // printf("meth=%s\n",meth);
  jlarg=(jl_value_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADDDR(args));
  func = jl_get_function(jl_main_module, meth);
  res = jl_call2(func, jlv,jlarg);
  resR=(SEXP)jlvalue(res);
  JL_GC_POP();
  
  return resR;
}

SEXP Rulia_jlvalue_call3(SEXP args) {
  char *meth;
  jl_value_t *jlv=NULL, *res=NULL, *jlarg=NULL, *jlarg2=NULL;
  jl_function_t *func=NULL;
  SEXP resR;

  meth = (char*)CHAR(STRING_ELT(CADR(args),0));
  JL_GC_PUSH5(&jlv,&func,&res,&jlarg,&jlarg2);
  jlv=(jl_value_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADDR(args));
  jlarg=(jl_value_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADDDR(args));
  jlarg2=(jl_value_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CAD4R(args));
  func = jl_get_function(jl_main_module, meth);
  res = jl_call3(func, jlv, jlarg, jlarg2);
  resR=(SEXP)jlvalue(res);
  JL_GC_POP();
  return resR;
}

SEXP Rulia_jlvalue_call(SEXP jl_meth, SEXP jl_args, SEXP jl_nargs) {
  char *meth;
  int nargs;
  jl_value_t **args;
  jl_value_t *res;
  jl_function_t *func;
  SEXP resR;

  // printf("type %d\n", TYPEOF(jl_args));
  if(TYPEOF(jl_args) != VECSXP) {
    return R_NilValue;
  }
  meth = (char*)CHAR(STRING_ELT(jl_meth,0));
  // printf("meth=%s\n",meth);
  nargs=INTEGER(jl_nargs)[0];
  // printf("nargs=%d\n",nargs);
  JL_GC_PUSHARGS(args, nargs);
  for(int i=0;i < nargs;i++) {
    args[i] = (jl_value_t*)(get_preserved_jlvalue_from_R_ExternalPtrAddr(VECTOR_ELT(jl_args,i)));
  }
  func = jl_get_function(jl_main_module, meth);
  res = jl_call(func, args, nargs);
  resR=(SEXP)jlvalue(res);
  JL_GC_POP();
  return resR;
}

SEXP Rulia_jlvalue_trycall(SEXP args) {
  jl_value_t *jlv=NULL, *res=NULL, *jlarg=NULL, *jlarg2=NULL;
  jl_function_t *func=NULL;
  SEXP resR;

  jl_module_t *jl_Rulia_module = (jl_module_t*)jl_get_global(jl_main_module, jl_symbol("Rulia"));
  func = jl_get_function(jl_Rulia_module, "jltrycall");

  JL_GC_PUSH4(&jlv,&res,&jlarg,&jlarg2);
  jlv=(jl_value_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADR(args));
  jlarg=(jl_value_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADDR(args));
  jlarg2=(jl_value_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADDDR(args));
  res = jl_call3(func, jlv, jlarg, jlarg2);
  resR=(SEXP)jlvalue(res);
  JL_GC_POP();
  return resR;
}

SEXP Rulia_jlvalue_tryfunc(SEXP args) {
  jl_value_t *res=NULL, *jlarg=NULL, *jlarg2=NULL;
  jl_function_t *func=NULL, *jlv=NULL;
  SEXP resR;

  jl_module_t *jl_Rulia_module = (jl_module_t*)jl_get_global(jl_main_module, jl_symbol("Rulia"));
  func = jl_get_function(jl_Rulia_module, "jltryfunc");

  JL_GC_PUSH4(&jlv,&res,&jlarg,&jlarg2);
  jlv = (jl_function_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADR(args));
  jlarg=(jl_value_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADDR(args));
  jlarg2=(jl_value_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADDDR(args));
  res = jl_call3(func, jlv, jlarg, jlarg2);
  resR=(SEXP)jlvalue(res);
  JL_GC_POP();
  return resR;
}

SEXP Rulia_jlvalue_func_call(SEXP jl_func, SEXP jl_args, SEXP jl_nargs) {
  int nargs;
  jl_value_t **args;
  jl_value_t *res;
  jl_function_t *func;
  SEXP resR;

  // printf("type %d\n", TYPEOF(jl_args));
  if(TYPEOF(jl_args) != VECSXP) {
    return R_NilValue;
  }
  // printf("meth=%s\n",meth);
  nargs=INTEGER(jl_nargs)[0];
  JL_GC_PUSHARGS(args, nargs);
  for(int i=0;i < nargs;i++) {
    args[i] = (jl_value_t*)(get_preserved_jlvalue_from_R_ExternalPtrAddr(VECTOR_ELT(jl_args,i)));
  }
  func = (jl_function_t*)(get_preserved_jlvalue_from_R_ExternalPtrAddr(jl_func));
  res = jl_call(func, args, nargs);
  resR=(SEXP)jlvalue(res);
  JL_GC_POP();
  return resR;
}

// SEXP Rulia_jlvalue_new_struct1(SEXP args) {
//   char *dt;
//   jl_value_t *jlv=NULL, *res=NULL;
//   jl_datatype_t *jldt = NULL; 
//   SEXP resR;

//   dt = (char*)CHAR(STRING_ELT(CADR(args),0));
//   JL_GC_PUSH3(&jlv,&jldt,&res);
//   jlv=(jl_value_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADDR(args));
//   jldt = (jl_datatype_t*)jl_eval_string(dt);
//   res = jl_new_struct(jldt, jlv);
//   resR=(SEXP)jlvalue(res);
//   JL_GC_POP();
//   return resR;
// }

SEXP Rulia_jlvalue_new_struct(SEXP jl_dt, SEXP jl_args, SEXP jl_nargs) {
  char *dt;
  int nargs;
  jl_value_t **args;
  jl_value_t *res;
  jl_datatype_t *jldt = NULL;
  SEXP resR;

  // printf("type %d\n", TYPEOF(jl_args));
  if(TYPEOF(jl_args) != VECSXP) {
    return R_NilValue;
  }
  dt = (char*)CHAR(STRING_ELT(jl_dt,0));
  jldt = (jl_datatype_t*)jl_eval_string(dt);
  // printf("meth=%s\n",meth);
  nargs=INTEGER(jl_nargs)[0];
  // printf("nargs=%d\n",nargs);
  JL_GC_PUSHARGS(args, nargs);
  for(int i=0;i < nargs;i++) {
    args[i] = (jl_value_t*)(get_preserved_jlvalue_from_R_ExternalPtrAddr(VECTOR_ELT(jl_args,i)));
  }
  res = jl_new_structv(jldt, args, nargs);
  resR=(SEXP)jlvalue(res);
  JL_GC_POP();
  return resR;
}

// SEXP Rulia_jlvalue_func_new_struct(SEXP args) {
//   jl_value_t *jlv=NULL, *res=NULL;
//   jl_function_t *func=NULL;
//   SEXP resR;

//   JL_GC_PUSH3(&jlv,&func,&res);
//   func = (jl_function_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADR(args));
//   jlv=(jl_value_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADDR(args));
//   res = jl_call1(func, jlv);
//   resR=(SEXP)jlvalue(res);
//   JL_GC_POP();
//   return resR;
// }

SEXP Rulia_jlvalue2R(SEXP args) {
  jl_value_t *jlv=NULL;
  SEXP resR;

  JL_GC_PUSH1(&jlv);
  jlv=(jl_value_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADR(args));
  resR = jl_value_to_SEXP(jlv);
  JL_GC_POP();
  return resR;
}

SEXP Rulia_typeof2R(SEXP args)
{
  jl_value_t *jlv=NULL;
  SEXP resR;

  JL_GC_PUSH1(&jlv);
  jlv=(jl_value_t*)get_preserved_jlvalue_from_R_ExternalPtrAddr(CADR(args));
  resR = jl_value_type(jlv);
  JL_GC_POP();
  return resR;
}

SEXP Rulia_show_preserved_ref(SEXP ans) {
  jl_value_t *res=NULL;
  jl_function_t* display=NULL;
  
  JL_GC_PUSH2(&res,&display);
    display = jl_get_function(jl_main_module, "display");
  res = get_preserved_jlvalue_from_R_ExternalPtrAddr(ans);
  jl_call1(display, res);
  JL_GC_POP();
  return R_NilValue;
}

SEXP Rulia_capture_preserved_ref(SEXP ans) {
  jl_value_t *res=NULL, *out=NULL;
  jl_function_t* display=NULL;
  SEXP outR;

  jl_module_t *jl_Rulia_module = (jl_module_t*)jl_get_global(jl_main_module, jl_symbol("Rulia"));
  JL_GC_PUSH3(&res,&display,&out);
  display = jl_get_function(jl_Rulia_module, "display_buffer");
  res = get_preserved_jlvalue_from_R_ExternalPtrAddr(ans);
  out=jl_call1(display, res);
  outR=(SEXP)jl_value_to_SEXP(out);
  JL_GC_POP();
  return outR;
}


#include <R_ext/Rdynload.h>
static const R_CMethodDef cMethods[] = {
  {NULL,NULL,0}
};

static const R_ExternalMethodDef externalMethods[] = {
  {"Rulia_init",(DL_FUNC) &Rulia_init,-1},
  {"Rulia_exit",(DL_FUNC) &Rulia_exit,-1},
  // {"Rulia_eval2R",(DL_FUNC) &Rulia_eval2R,-1},
  {"Rulia_run",(DL_FUNC) &Rulia_run,-1},
  {"Rulia_run_with_exception",(DL_FUNC) &Rulia_run_with_exception,-1},
  {"Rulia_set_global_variable",(DL_FUNC)&Rulia_set_global_variable,-1},
   // {"Rulia_as_Rvector",(DL_FUNC)&Rulia_as_Rvector,-1},
  // {"Rulia_as_jlRvector",(DL_FUNC)&Rulia_as_jlRvector,-1},
  {"Rulia_jlvalue_eval",(DL_FUNC) &Rulia_jlvalue_eval,-1},
  {"Rulia_jlvalue_trycall",(DL_FUNC) &Rulia_jlvalue_trycall,-1},
  {"Rulia_jlvalue_tryfunc",(DL_FUNC) &Rulia_jlvalue_tryfunc,-1},
  {"Rulia_jlvalue_call0",(DL_FUNC) &Rulia_jlvalue_call0,-1},
  {"Rulia_jlvalue_call1",(DL_FUNC) &Rulia_jlvalue_call1,-1},
  {"Rulia_jlvalue_call2",(DL_FUNC) &Rulia_jlvalue_call2,-1},
  {"Rulia_jlvalue_call3",(DL_FUNC) &Rulia_jlvalue_call3,-1},
  {"Rulia_jlvalue_func_call1",(DL_FUNC) &Rulia_jlvalue_func_call1,-1},
  {"Rulia_jlvalue2R",(DL_FUNC) &Rulia_jlvalue2R,-1},
  {"Rulia_typeof2R",(DL_FUNC) &Rulia_typeof2R,-1},
  {"Rulia_jl_symbol",(DL_FUNC) &Rulia_jl_symbol,-1},
  {NULL,NULL,0}
};

static const R_CallMethodDef callMethods[] = {
  {"Rulia_running",(DL_FUNC) &Rulia_running,0},
  {"Rulia_get_ans",(DL_FUNC) &Rulia_get_ans,0},
  {"Rulia_jlvalue_call",(DL_FUNC) &Rulia_jlvalue_call,3},
  {"Rulia_jlvalue_func_call",(DL_FUNC) &Rulia_jlvalue_func_call,3},
  {"Rulia_jlvalue_new_struct",(DL_FUNC) &Rulia_jlvalue_new_struct,3},
  {"Rulia_finalizeExternalPtr",(DL_FUNC) &Rulia_finalizeExternalPtr,1},
  {"Rulia_VECSXP_to_jl_array_EXTPTRSXP", (DL_FUNC)&Rulia_VECSXP_to_jl_array_EXTPTRSXP,1},
  {"Rulia_show_preserved_ref", (DL_FUNC)&Rulia_show_preserved_ref,1},
  {"Rulia_capture_preserved_ref", (DL_FUNC)&Rulia_capture_preserved_ref,1},
  {NULL,NULL,0}
};

void R_init_Rulia(DllInfo *info) {
  R_registerRoutines(info,cMethods,callMethods,NULL,externalMethods);
}

// OLD USELESS STUFF

// SEXP Rulia_as_Rvector(SEXP args)
// {
//   SEXP ans;
//   jl_value_t* jlobj;

//   if (inherits(CADR(args), "jlRvector")) {
//     jlobj=(jl_value_t*) R_ExternalPtrAddr(CADR(args));
//     ans=(SEXP)jl_value_to_SEXP(jlobj);
//     return ans;
//   } else return R_NilValue;
// }

// SEXP Rulia_as_jlRvector(SEXP args)
// {
//   jl_value_t* val;
//   SEXP ans;
//   val=(jl_value_t*)Vector_SEXP_to_jl_array(CADR(args));
//   ans=(SEXP)newJLObj(val);
//   return(ans);
// }

// SEXP newJLRVector(jl_value_t* jlobj) {
//   SEXP ans,class;

//   ans=(SEXP)makeJLObject(jlobj);
//   //if(rbIsRVector(jlobj)) {
//     PROTECT(class=allocVector(STRSXP,2));
//     SET_STRING_ELT(class,0, mkChar("jlRVector"));
//     SET_STRING_ELT(class,1, mkChar("jlObj"));
//   //} else {
//   //  PROTECT(class=allocVector(STRSXP,1));
//   //  SET_STRING_ELT(class,0, mkChar("jlObj"));
//   //}
//   //classgets(ans,class);
//   SET_CLASS(ans,class);
//   UNPROTECT(1);
//   return ans;
// }