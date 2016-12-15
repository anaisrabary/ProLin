/*
set MOIS 	:=  janvier fevrier mars avril mai juin;

set HUILES_VEGETALES 	:= VEG1 VEG2;
set HUILES_ANIMALES 	:= ANI1 ANI2 ANI3;
*/
set MOIS;
set HUILES_VEGETALES;
set HUILES_ANIMALES;
set TYPES := HUILES_VEGETALES union HUILES_ANIMALES;
set LINKS within {MOIS, TYPES};

param prix_achat {LINKS} >= 0;
param prix_vente 	>= 0;
param raf_max_vege 	>= 0;
param raf_max_anim 	>= 0;

/*param VEG1 {MOIS} >= 0;
param VEG2 {MOIS} >= 0;
param ANI1 {MOIS} >= 0;
param ANI2 {MOIS} >= 0;
param ANI3 {MOIS} >= 0;
*/

var quantite_vendue { MOIS, TYPES } >= 0; 

maximize profit :
	sum { t in TYPES } quantite_vendue['mars', t] * (prix_vente - prix_achat['mars', t]);
	
maximize profit_jan :
	sum { t in TYPES } quantite_vendue['janvier', t] * (prix_vente - prix_achat['janvier', t]);

/*minimize achat { m in MOIS }:
	sum { t in TYPES } quantite_vendue[m, t] * ;*/
	
subject to raffiner_vegetales { m in MOIS } :
	sum { v in HUILES_VEGETALES } quantite_vendue[m, v] <= raf_max_vege;
	
subject to raffiner_animales { m in MOIS } :	
	sum { a in HUILES_ANIMALES } quantite_vendue[m, a] <= raf_max_anim;