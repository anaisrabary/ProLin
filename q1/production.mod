set MOIS;
set HUILES_VEGETALES;
set HUILES_ANIMALES;
set TYPES := HUILES_VEGETALES union HUILES_ANIMALES;

param prix_achat { TYPES, MOIS } >= 0;
param prix_vente 	>= 0;
param raf_max_vege 	>= 0;
param raf_max_anim 	>= 0;

param durete_min >= 0;
param durete_max >= durete_min;
param durete { TYPES } >= 0;

var quantite_vendue { MOIS, TYPES } >= 0; 

maximize profit :
	sum { m in MOIS, t in TYPES } quantite_vendue[m, t] * (prix_vente - prix_achat[t, m]);
	
subject to raffiner_vegetales { m in MOIS } :
	sum { v in HUILES_VEGETALES } quantite_vendue[m, v] <= raf_max_vege;
	
subject to raffiner_animales { m in MOIS } :	
	sum { a in HUILES_ANIMALES } quantite_vendue[m, a] <= raf_max_anim;
