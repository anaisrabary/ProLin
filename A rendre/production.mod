set MOIS ordered; # indices numériques de 0 à 6
set HUILES_VEGETALES;
set HUILES_ANIMALES;
# Union des 2 paramètres :
set TYPES := HUILES_VEGETALES union HUILES_ANIMALES;
#...............................................................................
# Q1 Etape 1
param prix_achat { TYPES, MOIS } >= 0;
param prix_vente 	>= 0;
param raf_max_vege 	>= 0;
param raf_max_anim 	>= 0;

# Q1 Etape2
param durete { TYPES } >= 0;
param durete_min >= 0;
param durete_max >= 0;
# Q1 Etape 3
param stock_actuel >= 0;			# chaque huiles
param stock_max >=  stock_actuel; 	# chaque huiles
param cout_stock >= 0;				# par tonne et par mois	

# Q3 
param evolution{TYPES, MOIS} >= 0;
param x >= 0;
# tableau avec les nouveaux prix si évolution. x vaut 2 (donc 2%)
param prix_evolue {t in TYPES, m in MOIS} = prix_achat[t,m] + prix_achat[t,m]* x * 0.01 *evolution [t,m] ;

#------------------------------------------------------------------------------- 	
# Quantité de stock mensuelle à la fin du mois (début à décembre)
var quantite_stock { 0 .. 6, TYPES } >= 0; 
# quantité produite, raffinée, vendue
var quantite_vendue { MOIS, TYPES } >= 0;
# quantité achetée pouvant être stockée ou vendue après raffinage 	
var quantite_achat { MOIS, TYPES } >= 0;	
# c'est la somme des quantités vendues (donc raffinées) pour calculer la dureté
var quantite_total { m in MOIS } = sum { t in TYPES } quantite_vendue[m, t];

#------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------
maximize profit:
	# Q1, expression de profit :
	#sum {m in MOIS , t in TYPES } (quantite_vendue[m, t] * prix_vente - quantite_achat[m, t] * prix_achat[t, m] - quantite_stock[m, t] * cout_stock);
	
	# Q3
	# nouvelle fonction objectif avec le tableau des prix avec évolution
	sum {m in MOIS , t in TYPES } (quantite_vendue[m, t] * prix_vente - quantite_achat[m, t] * prix_evolue[t, m] - quantite_stock[m, t] * cout_stock);
#--------------------------------------------------------------------------------
#---------------------------------------------------------------------------------

# contraintes autour du raffinage
subject to raffiner_vegetales { m in MOIS } :
	sum { v in HUILES_VEGETALES } quantite_vendue[m, v] <= raf_max_vege;
	
subject to raffiner_animales { m in MOIS } :	
	sum { a in HUILES_ANIMALES } quantite_vendue[m, a] <= raf_max_anim;
	
# contraintes autour de la dureté
subject to durete_produit_min { m in MOIS }:
	0 <= sum { t in TYPES } (quantite_vendue[m, t] * durete[t]) - durete_min * quantite_total[m];

subject to durete_produit_max { m in MOIS }:
	sum { t in TYPES } (quantite_vendue[m, t] * durete[t]) - durete_max *quantite_total[m] <= 0;
	
# contraintes autour du stockage
subject to max_stock {m in MOIS, t in TYPES}:
	quantite_stock [m, t] <= stock_max;

subject to stock_init {t in TYPES}:
	quantite_stock [0, t] = stock_actuel;
	
subject to stock_final {t in TYPES}:
	quantite_stock[6, t] = stock_actuel;
	
subject to equilibre_stock{ m in MOIS, t in TYPES }:
	quantite_stock[m-1, t] + quantite_achat[m, t] - quantite_vendue[m,t] = quantite_stock[m, t];
	