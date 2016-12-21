set MOIS ordered;
set CATEGORIES;
set HUILES_VEGETALES;
set HUILES_ANIMALES;
set TYPES := HUILES_VEGETALES union HUILES_ANIMALES;

# Q1 Etape 1
param prix_achat { TYPES, MOIS } >= 0;	# prix d'achat par tonne selon type de l'huile et selon mois
param prix_vente 	>= 0;				# prix de vente par tonne 
param raf_max_vege 	>= 0;				# limite raffinage par mois pour l'huile végétale
param raf_max_anim 	>= 0;				# limite raffinage par mois pour l'huile animale

# Q1 Etape 2
param durete { TYPES } >= 0;	# dureté pour chaque types d'huiles
param durete_min >= 0;			# la borne inf de dureté de produit final
param durete_max >= 0;			# la borne sup de dureté de produit final

# Q1 Etape 3
param stock_actuel >= 0;			# chaque huiles
param stock_max >=  stock_actuel; 	# chaque huiles
param cout_stock >= 0;				# par tonne et par mois	

# Q3 
param evolution{ CATEGORIES, MOIS } >= 0;	# tableau de proportion estimée
param x >= 0;								# paramètre x de propotion d'évolution

param prix_evolue { t in TYPES, m in MOIS } = prix_achat[t, m]*(1 + x * 0.01 * evolution[if t in HUILES_VEGETALES then "HUILES_VEGETALES" else "HUILES_ANIMALES", m]); 	

#------------------------------------------------------------------------------- 	
# Quantité de stock mensuelle	
var quantite_stock { MOIS, TYPES } >= 0;
# Quantité produite, raffinée, vendue
var quantite_vendue { MOIS, TYPES } >= 0;
# quantité achetée pouvant être stockée ou vendue après raffinage 	
var quantite_achat { MOIS, TYPES } >= 0;
# c'est la somme des quantités vendues (donc raffinées) pour calculer la dureté
var quantite_total { m in MOIS } = sum { t in TYPES } quantite_vendue[m, t];

#------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------
maximize profit:
	#sum {m in MOIS , t in TYPES } (quantite_vendue[m, t] * prix_vente - quantite_achat[m, t] * prix_achat[t, m] - quantite_stock[m, t] * cout_stock);
	# nouvelle fonction objectif avec le tableau des prix avec évolution
	sum {m in MOIS , t in TYPES } (quantite_vendue[m, t] * prix_vente - quantite_achat[m, t] * prix_evolue[t, m] - quantite_stock[m, t] * cout_stock);

#------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------
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
	
subject to stock_final {t in TYPES}:
	quantite_stock[last(MOIS), t] = stock_actuel;
	
subject to equilibre_stock{ m in MOIS, t in TYPES }:
	(if m == first(MOIS) then stock_actuel else quantite_stock[prev(m), t]) + quantite_achat[m, t] - quantite_vendue[m,t] = quantite_stock[m, t];
	