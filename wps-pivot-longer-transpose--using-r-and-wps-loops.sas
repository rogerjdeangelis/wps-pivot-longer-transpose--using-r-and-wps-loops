%let pgm=wps-pivot-longer-transpose--using-r-and-wps-loops;

wps-pivot-longer-transpose--using-r-and-wps-loops

 SOLUTIONS

     1 wps
     2 wps r
     3 repos

github
http://tinyurl.com/ydx3272z
https://github.com/rogerjdeangelis/wps-pivot-longer-transpose--using-r-and-wps-loops

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
array col _1 _2 _3 _4 _5 _6 _7  ;
do row=1 to 3;
  do over col;
     col=int(90*uniform(9876)) + 10;
  end;
  output;
end;
drop row;
stop;
run;quit;

/**************************************************************************************************************************/
/*                            |                                                             |                             */
/*       INPUT                |                     PROCESSES                               |       OUTPUT                */
/*                            |                                                             |                             */
/* SD1.HAVE total obs=3       |    WPS R                                                    |                             */
/*                            |    ==================================                       |                             */
/* Obs   _1 _2 _3 _4 _5 _6 _7 |    nr=nrow(have);                                           | ORIGINAL_ ORIGINAL_         */
/*                            |    nc=ncol(have);                                           |   COLUMN     ROW    VALUE   */
/*  1    72 63 69 83 77 62 51 |    long <- matrix(nrow=nr*nc,ncol=3);                       |                             */
/*  2    98 78 47 63 77 20 56 |    lx=0;                                                    |     1         1       72    */
/*  3    61 17 38 77 57 98 12 |     for ( row in 1:nr) {                                    |     2         1       63    */
/*                            |       for ( col in 1:nc) {                                  |     3         1       69    */
/*                            |         lx=lx+1;                                            |     4         1       83    */
/*                            |         long[lx,1]   = col;                                 |     5         1       77    */
/*                            |         long[lx,2]   = row;                                 |     6         1       62    */
/*                            |         long[lx,3]   = have[row,col];                       |     7         1       51    */
/*                            |     }};                                                     |     1         2       98    */
/*                            |    want<-as.data.frame(long);                               |     2         2       78    */
/*                            |    names(want)=c("ORIGINAL_COLUMN","ORIGINAL_ROW","VALUE"); |     3         2       47    */
/*                            |                                                             |     4         2       63    */
/*                            |    WPS                                                      |     5         2       77    */
/*                            |    ===================================                      |     6         2       20    */
/*                            |    set sd1.have nobs=rows;                                  |     7         2       56    */
/*                            |    array col _1 _2 _3 _4 _5 _6 _7  ;                        |     1         3       61    */
/*                            |    do original_row=1 to rows;                               |     2         3       17    */
/*                            |      do over col;                                           |     3         3       38    */
/*                            |        original_column=substr(vname(col),2);                |     4         3       77    */
/*                            |        value=col;                                           |     5         3       57    */
/*                            |        output;                                              |     6         3       98    */
/*                            |      end;                                                   |     7         3       12    */
/*                            |    end;                                                     |                             */
/*                            |                                                             |                             */
/**************************************************************************************************************************/

/*
/ | __      ___ __  ___
| | \ \ /\ / / `_ \/ __|
| |  \ V  V /| |_) \__ \
|_|   \_/\_/ | .__/|___/
             |_|
*/

proc datasets lib=sd1 nolist mt=data mt=view nodetails;delete want; run;quit;

%utl_submit_wps64x('
libname sd1 "d:/sd1";
data sd1.want;
  length  original_column $2.;
  set sd1.have nobs=rows;
  array col _1 _2 _3 _4 _5 _6 _7  ;
  do original_row=1 to rows;
    do over col;
      original_column=substr(vname(col),2);
      value=col;
      output;
    end;
  end;
  drop _:;
  stop;
run;quit;
proc print split="_";
run;quit;
');

/**************************************************************************************************************************/
/*                                                                                                                        */
/*  ORIGINAL_ ORIGINAL_                                                                                                   */
/*    COLUMN     ROW    VALUE                                                                                             */
/*                                                                                                                        */
/*      1         1       72                                                                                              */
/*      2         1       63                                                                                              */
/*      3         1       69                                                                                              */
/*      4         1       83                                                                                              */
/*      5         1       77                                                                                              */
/*      6         1       62                                                                                              */
/*      7         1       51                                                                                              */
/*      1         2       98                                                                                              */
/*      2         2       78                                                                                              */
/*      3         2       47                                                                                              */
/*      4         2       63                                                                                              */
/*      5         2       77                                                                                              */
/*      6         2       20                                                                                              */
/*      7         2       56                                                                                              */
/*      1         3       61                                                                                              */
/*      2         3       17                                                                                              */
/*      3         3       38                                                                                              */
/*      4         3       77                                                                                              */
/*      5         3       57                                                                                              */
/*      6         3       98                                                                                              */
/*      7         3       12                                                                                              */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*                    ____
__      ___ __  ___  |___ \  __      ___ __  ___   _ __
\ \ /\ / / `_ \/ __|   __) | \ \ /\ / / `_ \/ __| | `__|
 \ V  V /| |_) \__ \  / __/   \ V  V /| |_) \__ \ | |
  \_/\_/ | .__/|___/ |_____|   \_/\_/ | .__/|___/ |_|
         |_|                          |_|
*/

proc datasets lib=sd1 nolist mt=data mt=view nodetails;delete want; run;quit;

%utl_submit_wps64('
libname sd1 "d:/sd1";
proc r;
export data=sd1.have r=have;
submit;
libname(tidyverse);
have <- as.matrix(have);
nr=nrow(have);
nc=ncol(have);
long <- matrix(nrow=nr*nc,ncol=3);
lx=0;
 for ( row in 1:nr) {
   for ( col in 1:nc) {
     lx=lx+1;
     long[lx,1]   = col;
     long[lx,2]   = row;
     long[lx,3]   = have[row,col];
 }};
want<-as.data.frame(long);
names(want)=c("ORIGINAL_COLUMN","ORIGINAL_ROW","VALUE");
want;
endsubmit;
import data=sd1.want r=want;
run;quit;
proc print data=sd1.want split="_";
run;quit;
');

/**************************************************************************************************************************/
/*                                                                                                                        */
/*        ORIGINAL    ORIGINAL                                                                                            */
/* Obs     COLUMN       ROW       VALUE                                                                                   */
/*                                                                                                                        */
/*   1        1           1         72                                                                                    */
/*   2        2           1         63                                                                                    */
/*   3        3           1         69                                                                                    */
/*   4        4           1         83                                                                                    */
/*   5        5           1         77                                                                                    */
/*   6        6           1         62                                                                                    */
/*   7        7           1         51                                                                                    */
/*   8        1           2         98                                                                                    */
/*   9        2           2         78                                                                                    */
/*  10        3           2         47                                                                                    */
/*  11        4           2         63                                                                                    */
/*  12        5           2         77                                                                                    */
/*  13        6           2         20                                                                                    */
/*  14        7           2         56                                                                                    */
/*  15        1           3         61                                                                                    */
/*  16        2           3         17                                                                                    */
/*  17        3           3         38                                                                                    */
/*  18        4           3         77                                                                                    */
/*  19        5           3         57                                                                                    */
/*  20        6           3         98                                                                                    */
/*  21        7           3         12                                                                                    */
/*                                                                                                                        */
/**************************************************************************************************************************/
/*
 _ __ ___ _ __   ___  ___
| `__/ _ \ `_ \ / _ \/ __|
| | |  __/ |_) | (_) \__ \
|_|  \___| .__/ \___/|___/
         |_|
*/

REPO
------------------------------------------------------------------------------------------------------------------------------
https://github.com/rogerjdeangelis/utl_an_unsusual_transpose_based_on__groups_of_variable_names
https://github.com/rogerjdeangelis/utl_classic_transpose_in_r_and_sas
https://github.com/rogerjdeangelis/utl_diagonal_transpose_while_keeping_all_original_rows
https://github.com/rogerjdeangelis/utl_excel_Import_and_transpose_range_A9-Y97_using_only_one_procedure
https://github.com/rogerjdeangelis/utl_flexible_complex_multi-dimensional_transpose_using_one_proc_report
https://github.com/rogerjdeangelis/utl_simple_three_dimensional_transpose_in_r_and_sas
https://github.com/rogerjdeangelis/utl_sophisticated_transpose_with_proc_summary_idgroup
https://github.com/rogerjdeangelis/utl_sort_summarize_and_transpose_multiple_variable_and_create_output_dataset
https://github.com/rogerjdeangelis/utl_sort_summarize_transpose_and_format_in_1_datastep
https://github.com/rogerjdeangelis/utl_sort_transpose_and_summarize_a_dataset_using_just_one_proc_report
https://github.com/rogerjdeangelis/utl_sort_transpose_and_summarize_in_one_proc_v2
https://github.com/rogerjdeangelis/utl_sort_transpose_summarize
https://github.com/rogerjdeangelis/utl_sql_version_of_proc_transpose_with_major_advantage_of_summarization
https://github.com/rogerjdeangelis/utl_techniques_to_transpose_and_stack_multiple_variables
https://github.com/rogerjdeangelis/utl_transpose_and_concatenate_observations_by_id_in_one_datastep
https://github.com/rogerjdeangelis/utl_transpose_long_to_wide_with_sequential_matching_pairs
https://github.com/rogerjdeangelis/utl_transpose_multiple_variables_and_split_variables_into_multiple_variables
https://github.com/rogerjdeangelis/utl_transpose_rows_to_column_identifying_type_of_data
https://github.com/rogerjdeangelis/utl_transpose_table_by_two_variables_not_supported_by_proc_transpose
https://github.com/rogerjdeangelis/utl_transpose_with_multiple_id_values_per_group
https://github.com/rogerjdeangelis/utl_transpose_with_proc_report
https://github.com/rogerjdeangelis/utl_transpose_with_proc_sql
https://github.com/rogerjdeangelis/utl_transposing_multiple_variables_with_different_ids_a_single_transpose_cannot_do_this
https://github.com/rogerjdeangelis/utl_two_families_itinerary_through_italy_transpose
https://github.com/rogerjdeangelis/utl_using_a_hash_to_transpose_and_reorder_a_table

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
