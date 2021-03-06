# pr�f�rences de danses
set skating::gui(pref:dances) {
	"Valse lente" "Tango" "Quickstep" "Valse viennoise" "Slow Foxtrot"
	----
	"Cha Cha" "Rumba" "Jive" "Samba" "Paso Doble"
	----
	"Salsa" "Mambo" "Rock'n Roll"
	----
	"Valse Musette" "Java"
}
set skating::gui(pref:dances:short) {
	"VL" "TA" "QS" "VV" "SF"
	----
	"CC" "RU" "JV" "SA" "PD"
	----
	"S" "M" "RR"
	----
	"VM" "J"
}

array set skating::gui {
	pref:templates		{0 1 2 3 4 5 6 7 8 9}

	pref:template:name:0	{2 Standards}
	pref:template:dances:0	{{Valse lente} Tango}
	pref:template:name:1	{3 Standards}
	pref:template:dances:1	{{Valse lente} Tango Quickstep}
	pref:template:name:2	{4 Standards}
	pref:template:dances:2	{{Valse lente} Tango Quickstep {Valse viennoise}}
	pref:template:name:3	{5 Standards}
	pref:template:dances:3	{{Valse lente} Tango {Slow Foxtrot} Quickstep {Valse viennoise}}

	pref:template:name:4	{2 Latines}
	pref:template:dances:4	{{Cha Cha} Rumba}
	pref:template:name:5	{3 Latines}
	pref:template:dances:5	{{Cha Cha} Rumba Jive}
	pref:template:name:6	{4 Latines}
	pref:template:dances:6	{{Cha Cha} Samba Rumba Jive}
	pref:template:name:7	{5 Latines}
	pref:template:dances:7	{{Cha Cha} Samba Rumba {Paso Doble} Jive}

	pref:template:name:8	{Dix danses (Std + Lat)}
	pref:template:dances:8	{{Valse lente} Tango {Slow Foxtrot} Quickstep {Valse viennoise} {Cha Cha} Samba Rumba {Paso Doble} Jive}
	pref:template:name:9	{Dix danses (Lat + Std)}
	pref:template:dances:9	{{Cha Cha} Samba Rumba {Paso Doble} Jive {Valse lente} Tango {Slow Foxtrot} Quickstep {Valse viennoise}}
}

set ::currentLanguage "french"

# messages
array set msg {
	round:				""
	round:__result__	""

	round:finale		"Finale"
	round:prefinale		"Pre-Finale"
	round:semi			"1/2 Finale"
	round:quarter		"1/4 Finale"
	round:eight			"1/8 Finale"
	round:16			"1/16 Finale"
	round:32			"1/32 Finale"
	round:64			"1/64 Finale"
	round:128			"1/128 Finale"
	round:256			"1/256 Finale"
	round:512			"1/512 Finale"
	round:1024			"1/1024 Finale"
	round:finale.2		""
	round:prefinale.2	""
	round:semi.2		"1/2 Finale (+)"
	round:quarter.2		"1/4 Finale (+)"
	round:eight.2		"1/8 Finale (+)"
	round:16.2			"1/16 Finale (+)"
	round:32.2			"1/32 Finale (+)"
	round:64.2			"1/64 Finale (+)"
	round:128.2			"1/128 Finale (+)"
	round:qualif		"Qualification"

	round:short:			""
	round:short:all			"Tous"
	round:short:finale		"F"
	round:short:prefinale	"PreF"
	round:short:semi		"1/2"
	round:short:quarter		"1/4"
	round:short:eight		"1/8"
	round:short:16			"1/16"
	round:short:32			"1/32"
	round:short:64			"1/64"
	round:short:128			"1/128"
	round:short:256			"1/256"
	round:short:512			"1/512"
	round:short:1024		"1/1024"
	round:short:semi.2		"1/2+"
	round:short:quarter.2	"1/4+"
	round:short:eight.2		"1/8+"
	round:short:16.2		"1/16+"
	round:short:32.2		"1/32+"
	round:short:64.2		"1/64+"
	round:short:128.2		"1/128+"
	round:short:qualif		"Qualif"



	dlg:abort			"Abandonner"
	dlg:retry			"Ressayer"
	dlg:ignore			"Ignorer"
	dlg:ok				"OK"
	dlg:cancel			"Annuler"
	dlg:yes				"Oui"
	dlg:no				"Non"
	dlg:print			"Imprimer"
	dlg:save			"Sauver"
	dlg:saveAs			"Sauver sous ..."
	dlg:saveAsDefault	"Sauver comme param�tres par d�fault"
	dlg:options			"Options ..."
	dlg:layout			"Mise en page ..."
	dlg:question		"Question"
	dlg:information		"Information"
	dlg:error			"Erreur"
	dlg:modifiedSave	"Les donn�es en cours ont �t� modif�es.\n\nVoulez-vous les enregistrer avant de quitter ?"
	dlg:modifiedDB		"La base de donn�es pour la saisie rapide a �t� modifi�e.\n\nVoulez-vous enregistrer les changements avant de quitter ?"
	dlg:reallyQuit		"Quitter le programme ?"
	dlg:loadDBFailed	"Erreur lors du chargement de la base de donn�es.\n"
	dlg:saveDBFailed	"Impossible de sauver la base de donn�e.\n\nV�rifiez que le disque n'est pas plein ou prot�g� en �criture."
	dlg:saveDefaultsFailed "Une erreur est survenue lors de la sauvegarde des param�tres par d�faut."
	dlg:dancesReinit	"Retirer cette dance qui est utilis�e dans les s�lections entra�ne la r�-initialisation des notes � partir du round o� elle est utilis�e.\n\nVoulez-vous continuer ?"
	dlg:dancesReinit2	"Retirer cette dance qui est utilis�e dans la finale entra�ne la perte des notes entr�es pour la finale pour cette danse.\n\nVoulez-vous continuer ?"
	dlg:couplesReinit	"Changer la s�lection des couples entra�ne la r�-initialisation des notes d�j� entr�es.\n\nVoulez-vous continuer ?"
	dlg:judgesReinit	"Changer le choix des juges entra�ne la r�-initialisation des notes d�j� entr�es.\n\nVoulez-vous continuer ?"
	dlg:roundModeReinit	"Changer le mode de gestion des rounds entra�ne la r�-initialisation des notes d�j� entr�es.\n\nVoulez-vous continuer ?"
	dlg:notDefined		"Vous devez d�finir les danses, les couples et les juges avant de s�lectionner un round."
	dlg:notSelected		"Vous devez s�lectionner les couples dans les rounds pr�c�dents."
	dlg:coupleOne		"Le couple"
	dlg:coupleMany		"Les couples"
	dlg:judgeOne		"Le juge"
	dlg:judgeMany		"Les juges"
	dlg:coupleUsed		"Impossible de supprimer le couple utilis� dans :"
	dlg:coupleUseAlias	"Impossible de supprimer ce couple car des alias existent."
	dlg:judgeUsed		"Impossible de supprimer le juge utilis� dans :"
	dlg:removePanel		"Voulez-vous vraiment supprimer le panel "
	dlg:removeTemplate	"Voulez-vous vraiment supprimer le mod�le "
	dlg:confirmDelete	"Voulez-vous vraiment supprimer cette comp�tition ?"
	dlg:confirmDelete2	"Voulez-vous vraiment supprimer les comp�tition existantes mais d�selectionn�es ?"
	dlg:confirmDiscard	"Les donn�es en cours ont �t� modif�es.\n\nSi vous continuez, vous perdrez vos modifications."
	dlg:cantOpen		"Impossible d'ouvrir le fichier"
	dlg:cantSave		"Impossible d'enregistrer le fichier"
	dlg:loadTooRecent	"Le fichier que vous avez charg� a �t� g�n�r� par une version plus r�cente du programme. Certaines donn�es ne seront pas exploit�es et seront perdues si vous sauvez le fichier.\n\nMettez � jour la version de votre logiciel (http://laurent.riesterer.free.fr/skating/download.html)."
	dlg:resetRounds		"Les couples pour le round suivant sont d�j� d�finis.\n\nSi vous continuez, les donn�es d�j� entr�es seront perdus."
	dlg:notImplemented	"Fonction non encore impl�ment�e."
	dlg:langFailed		"Erreur lors du chargement des pr�f�rences de langage."
	dlg:prefFailed		"Erreur lors du chargement des pr�f�rences utilisateur."
	dlg:templatesFailed	"Erreur lors du chargement des mod�les de comp�titions."
	dlg:bugReport		"Erreur interne dans le programme.\n\nEnvoyer un message � laurent.riesterer@free.fr, enjoignant le fichier '3s.bugreport' qui se trouve dans le r�pertoire d'installation du programme."
	dlg:openPrinter		"Impossible d'acc�der � l'imprimante."
	dlg:demoMode		"Fichier de licence invalide ou expir�e. Le programme fonctionnera en mode d'�valuation (sauvegarde et impression limit�es)."
	dlg:demoSave		"Seule la premi�re comp�tition sera sauv�e dans la version d'�valuation.\nConsulter http://laurent.riesterer.free.fr/skating pour enregistrer votre version."
	dlg:demoPrint		"Seule la premi�re page sera imprim�e dans la version d'�valuation.\nConsulter http://laurent.riesterer.free.fr/skating pour enregistrer votre version."
	dlg:demoNotAvailable "Non disponible dans la version d'�valuation.\nConsulter http://laurent.riesterer.free.fr/skating pour enregistrer votre version."
	dlg:pleaseWait		"Patientez quelques instants ..."
	dlg:cannotWrite		"Le programme ne peut pas �crire dans '%s'.\n\nV�rifier que vous n'�tes pas sur un CD-ROM ou que les permissions sont correctement positionn�es."
	dlg:errorWrite		"Le programme n'a pas pu achever la sauvegarde. V�rifier que votre disque ne soit pas plein."
	dlg:errorWriteBackup "Une sauvegarde d'urgence a �t� sauv�e dans '%s'. Merci de la faire parvenir � l'auteur pour analyse."
	dlg:cannotWeb		"Le programme n'a pas pu g�n�rer la partie du Web pour '%s'."
	dlg:webDone			"Le site Web a �t� g�n�r� avec succ�s.\n\nLe page d'index se trouve en \"%s\""
	dlg:panelLocked		"Le panel est utilis� dans des comp�titions d�j� commenc�es. On ne peut plus le modifier.\n\nPour apporter des modifications, cr�er un nouveau panel et r�-affecter ce panel aux comp�titions restantes."

	dlg:editdance		"Edition de la danse"
	dlg:editdanceLabel	"Entrez le nom de la danse:"
	dlg:editdanceShortLabel	"Entrez l'abbr�viation:"
	dlg:editgroups		"Edition des groupes"

	dlg:plugin			"Choix de plug-in"
	dlg:quickinput		"Saisie rapide"
	dlg:standard		"Mode standard"
	dlg:new:msg			"Vous pouvez cr�er rapidement des couples et des juges.\nUtilisez les spinboxes ci-dessous."
	dlg:new:couples		"Couples num�rot�s de"
	dlg:new:couples2	"�"
	dlg:new:judges		"Nombre de juges"

	dlg:print:from		"Imprimer les pages de"
	dlg:print:to		"�"
	dlg:print:all		"tout"
	dlg:print:page		"page courante"

	dlg:OCM:errLogin	"Cannot login to the OCM system"
	dlg:OCM:noHeatId	"No heatID defined for this competition, please regenerate the file"


	setting				"Pr�f�rences"
	event				"Ev�nement"
	eventManagement		"Gestion �v�nement"
	general				"G�n�ral"
	attributes			"Attributs"
	dances				"Danses"
	other				"Autre"
	notation			"Syst�me de notation"
	notation:normal		"normal"
	notation:ten		"dix danses"
	notation:qualif		"qualification round"
	notation:tree		"hierarchique"
	templates			"Mod�les"
	add:template		"Ajouter\nun mod�le"
	remove:template		"Supprimer\nun mod�le"
	edit				"Editer ..." 
	load				"Charger ..." 
	save				"Sauver ..."
	search				"Chercher"
	replace				"Remplacer"
	except				"sauf"
	create				"Cr�er"
	useCountry			"'Pays' au lieu \nde 'Ecole/club'"
	to					"Jusqu'�"
	from				"A partir de"
	remove				"Enlever"
	removeall			"Tout enlever"
	insert:before		"Ins�rer avant"
	insert:after		"Ins�rer apr�s"
	numberSorting		"Tri des dossards"
	redisplay			"R�affichage\n(tri par num.)"
	redisplay2			"R�affichage\n(tri par lettre)"
	toclip				"Copier tout"
	fromclip			"Coller"
	fromclip2			"Tout enlever\n& coller"
	add:panel			"Ajouter\nun panel"
	remove:panel		"Supprimer\nun panel"
	Couple				"Couple"
	couples				"Couples"
	couples:none		"Aucun couple s�lectionn�"
	couples:one			"couple s�lectionn�"
	couples:twoAndMore	"couples s�lectionn�s"
	couples:among		"couples sur"
	judge				"Juge"
	judges				"Juges"
	Round				"Round"
	rounds				"Rounds"
	roundManagement		"Gestion des rounds"
	selection			"S�lection"
	sortby				"Trier par"
	sortby:number		"num�ro"
	sortby:name			"nom"
	sortby:school		"�cole"
	sortby:country		"pays"
	startingRound		"Round de d�part pour "
	startIn				"Round de d�part: "
	name				"Nom"
	input				"Saisie"
	deselectAll			"D�selectionner tous les juges"
	all					"Tous"
	none				"Aucun"
	copyFrom			"Copier"
	sameAs				"M�mes couples que pour ..."
	selectByPanel		"S�lection par les panels"
	getMarksFromOCM		"R�cup�rer notes OCM"
	couplesToExclude	"Couples � exclure"
	keep				"Prise en compte"
	useInResult			"danse utilis�e pour les r�sultats"
	hint				"Indication"
	Heats				"Heats"
	active				"activ�es"
	select				"S�lectionnez"
	rescue				"Rep�chez"
	among				"couples sur les"
	competing			"en lice"
	remaining			"restants"
	createPreFinale		"Cr�er une pre-finale"
	result				"R�sultat"
	selectionCouples	"S�lection des couples"
	keepCouples			"Couples � reprendre"
	splitCouples1		"Partager en"
	splitCouples2		"groupes"
	splitAdjust	     	"Ajuster"
	nextRound			"Round suivant"
	validation			"Validation"
	force				"Forcer"
	date				"Date"
	title				"Titre"
	comment				"Commentaires"
	attributes			"Attributs"
	attributes:_place	"Lieu"
	attributes:_organizer "Organisateur"
	attributes:_masterCeremony "Ma�tre de c�r�monie"
	attributes:_chairman "Chairman"
	attributes:_music	"Musique"
	attributes:_scrutineer "Scrutineer(s)"
	attributes:_support	"Logistique"
	attributes:_member	"Membre IDSF"
	uptodate			"A jour"
	apply				"Appliquer"
	competitions		"Comp�titions"
	define				"D�finir"
	choose				"Parcourir ..."
	rename				"Renommer"
	choice				"Choix"
	compSelected0		"Aucune comp�tition s�lectionn�e (sur %2$d comp�titions d�finies)"
	compSelected1		"%1$d comp�tition s�lectionn�e (sur %2$d comp�titions d�finies)"
	compSelected2		"%1$d comp�titions s�lectionn�es (sur %2$d comp�titions d�finies)"


	help:couples:edit	{"Edition d'une cellule:" blue \
						"\tF2, double-clic ou saisie directe (Escape pour annuler)\n" normal \
						"Ajout d'un couple:" blue \
						"\tUtilisez les boutons d'insertion ou allez � la derni�re ligne" normal}
	help:couples:error	"ERREUR: num�ro de couple d�j� utilis�"
	help:couples:alias	"ERREUR: alias impossible car couple racine inexistant"
	help:couples:alias2	"ERREUR: impossible de renommer le couple car il poss�de des alias"
	help:couples:paste1	"ERREUR: impossible de lire le presse-papier (vide ou format non support�)"
	help:couples:paste2	"ERREUR: num�ros de couples dupliqu�s dans le presse-papier"
	help:couples:paste3	"ERREUR: num�ro de couple du presse papier en conflit"
	help:judges:edit	{"Edition d'une cellule:" blue \
						"\tF2, double-clic ou saisie directe (Escape pour annuler)\n" normal \
						"Enlever un juge:" blue \
						"\tUtilisez les boutons sur la droite" normal}
	help:judges:error	"ERREUR: lettre de juge d�j� utilis�e"
	help:judges:paste1	"ERREUR: impossible de lire le presse-papier (vide ou format non support�)"
	help:judges:paste2	"ERREUR: lettre de juges dupliqu�s dans le presse-papier"
	help:judges:paste3	"ERREUR: lettre de juge du presse papier en conflit"
	help:judges:paste4	"ERREUR: format du juge incorrect : doit �tre LETTRE + (optionnel) LETTRE ou CHIFFRE"
	help:panels:edit	{"Edition du nom:" blue \
						"\tF2 ou double-clic sur le nom (Escape pour annuler)\n" normal}
	help:templates:edit	{"Edition de la danse:" blue \
						"\tdouble-clic sur le nom (Escape pour annuler)\n" normal \
"Ordre des danses:" blue \
						"\tUtiliser les boutons Haut/Bas\n" normal}
	help:finale			{"Gauche,droite,haut,bas, home et fin" blue \
						"\td�placement dans le tableau\n" normal \
						"1 � 9" blue \
						"\tentr�e d'une note pour le couple et la danse s�lectionn�e\n" normal \
						"A � Z" blue \
						"\ttapez la lettre d'un juge pour activer sa zone de saisie" normal}
	help:couples:groups	{"Affecter les couples dans les plages de dossards.\nCliquer sur OK pour r�affecter les dossards par ordre alphab�tique � l'int�rieur de chaque plage." blue }


	number				"Num."
	name				"Nom"
	man					"Homme"
	lady				"Femme"
	category			"Cat�gorie"
	school				"Ecole"
	schoolClub			"Ecole/Club"
	country				"Pays"
	letter				"Lettre"
	label				"Intitul�"
	Panel				"Panel"
	Panels				"Panels"
	panel				"panel"
	panels				"panels"
	allJudges			"Tous les juges"
	noJudges			"Aucun juge"

	add					"Ajouter"
	modify				"Modifier"
	merge				"Fusionner"
	clearall			"Effacer tout"
	database			"Bases de donn�es"
	automatic			"Automatique"
	manual				"Manuelle"
	select2				"s�lectionner"
	secondChance		"rep�chage"
	firstChance			"�liminatoires"
	naming				"Utiliser des noms explicites"
	50%rule				"Forcer 50% des s�lectionn�s d'un round au suivant"

	newCompetition		"Nouvelle comp�tition"
	newJudge			"Nouveau juge"
	noName				"sans nom"
	fileDatabase		"Fichiers Skating/Base de donn�es"
	fileSkating			"Fichiers Skating"
	fileSkatingPref		"Fichiers Skating/Pr�f�rences"
	fileSkatingSkt		"Fichiers Skating/Mod�les"
	fileText			"Fichiers texte"
	filePostscript		"Fichiers Postscript"
	fileImages			"Fichiers images"
	fileLanguage		"Fichiers de langues"
	fileAll				"Tous les fichiers"
	dancesSelection		"S�lection des danses"
	ranking				"Classement"
	rankingFinal		"Classement final"
	byCouple			"Par couple"
	byPlace				"Par place"
	place				"Place"
	best				"Round"
	summary				"R�sum�"
	tot					"Tot."
	total				"Total"
	remarks				"Remarques"
	excludedFrom		"Exclus de"
	rule				"R�gle"
	print				"Impression"
	couplesAndJudges	"couples & juges"
	judgesOnly			"juges seulements"
	judgesEnrollment	"table juges/comp�titions"
	listPanels			"liste des panels"
	listPanels:perRow	"panels par ligne"
	checkEnrollment		"table couples/comp�titions pour v�rification des participations"
	checkEnrollment:number "par num�ro"
	checkEnrollment:alphabetic "par ordre alphab�tique"
	checkEnrollment:groupBySchool "grouper d'abord par �cole/club"
	checkEnrollment:groupByCountry "grouper d'abord par pays"
	checkEnrollment:pageBreak "imprimer chaque �cole/club sur une page s�par�e"
	checkEnrollment:pageBreak2 "imprimer chaque pays sur une page s�par�e"
	checkEnrollment:withResults "imprimer les r�sultats disponibles"
	competitionsEnrollment "table couples & juges par comp�tition"
	competitionsEnrollment:judges "imprimer les juges"
	competitionsEnrollment:dances "imprimer les danses"
	competitionsEnrollment:select "imprimer le nombre couples � s�lectionner"
	competitionsEnrollment:pageBreak2 "commencer chaque comp�tition sur une nouvelle page"
	competitionsList	"liste des comp�titions"

	resultCompetition	"r�sultat de la comp�tition s�lectionn�e"
	resultFor			"r�sultats de"
	wholeCompetition	"comp�tition s�lectionn�e"
	round				"round s�lectionn�"
	folderSummary:place	"bilan de la comp�tition (par place)"
	folderSummary:couple "bilan de la comp�tition (par couple)"
	forRound			"pour le round"
	summary:place		"bilan par place"
	summary:couple		"bilan par couple"
	dance:place			"chaque danse par place"
	dance:couple		"chaque danse par couple"
	full				"d�tails pour chaque danse"
	idsf:report			"rapport IDSF"
	idsf:table			"table des r�sultats IDSF"
	markSheetsLayout	"Mise en page"
	portrait			"portrait"
	landscape			"paysage"
	orientation			"Orientation du papier"
	judgesInSummary		"Impression de la liste des juges dans les r�sum�s"
	judgesInSummary:0	"sur une page s�par�e"
	judgesInSummary:1	"sur chaque page"
	of					"de"
	printing			"Impression en cours"
	printing:msg		"Comp�titions trait�es :"
	printing:page		"Impression de la page"
	page				"page"
	pages				"pages"
	marksSheets			"Feuilles pour les juges"
	resultsSheets		"R�sultats"
	eventSheets			"Donn�es globales"
	webOutput			"Internet"
	copies				"Nombre de copies"
	print:options		"Options"
	print:rounds		"Imprimer des r�sultats"
	print:summaries		"Imprimer des bilans r�capitulatifs"
	print:all			"Impression pour toutes les comp�titions"
	all:rounds 			"d�tails de tous rounds"
	separateInputGrid	"Zone de saisie s�par�e pour les num�ro"
	yes					"oui"
	yes,				"oui,"
	no					"non"
	heatsGeneration		"G�n�ration automatique des heats"
	heatsIn				"soit"
	heatsSize			"taille"
	heatsSizeDefault	"Taille des heats demand�e"
	heatsCouplesGrouping "Mode pour le groupage des couples"
	heatsNumber			"num�ro"
	heatsAlphabetic		"alphab�tique"
	heatsRandom			"al�atoire"
	heatsMarkingSheets	"Imprimer les feuilles pour les juges"
	heatsPrint?			"Imprimer les feuilles pour les juges avec la liste des heats"
	heatsSheets			"oui"
	heatsNoSheets		"non, juste la liste des couples et des heats"
	heatsPrintLists		"Imprimer les listes pour le round"
	heatsListNone		"aucune"
	heatsListJudges		"juges"
	heatsListDances		"danses"
	heatsListBoth		"juges & danses"
	heatsCompact?		"Imprimer les danses"
	heatsCompact?2		"Imprimer toutes les danses sur une seule page"
	heatsCompact		"toutes sur une page"
	heatsNoCompact		"une danse par page"
	spareBoxes			"Cases suppl�mentaires"
	spareBoxes1			"Ajouter"
	spareBoxes2			"cases pour entr�es de retardataires"
	signSheets			"Signature des feuilles par les juges"
	newSheetOnJudge?	"Imprimer chaque juge"
	newSheetOnJudgeY	"sur une nouvelle feuille"
	newSheetOnJudgeN	"� la suite"
	newSheetOnJudge		"Commencer chaque juge sur une nouvelle feuille"

	web:parameters		"Param�tres"
	web:outputdir		"R�pertoire de sortie"
	web:filenameSKA		"Nom du fichier au format .SKA"
	web:filenameZIP		"Nom de l'archive du site g�n�r�"
	web:customization	"Personnalisation"
	web:links			"Liens suppl�mentaires"
	web:links:header	""
	web:links:data		""
	web:email			"Adresse e-mail"
	web:logo			"Logo � ins�rer dans les pages"
	web:headers			"R�p�tition des headers"
	web:repeatCouples	"num�ro du couple toutes les"
	web:repeatCouples:2	"danses"
	web:repeatHeader	"g�n�ral tout les"
	web:repeatHeader:2	"couples"
	web:repeatHeaderSummary	"g�n�ral dans les bilans tout les"
	web:repeatHeaderSummary:2 "couples"
	web:output			"Donn�es � g�n�rer"
	web:output:rounds	"rounds & finale"
	web:output:summaries "bilans par couple & place"
	web:output:idsf		"donn�es IDSF"
	web:generating		"G�n�ration du site Web"
	web:generating:msg	"Comp�titions trait�es :"
	web:generating:page	"Pages g�n�r�es"


	options:general		"G�n�ral"
	options:colors		"Couleurs"
	options:rounds		"Rounds & finale"
	options:print		"Impression"
	options:print2		"Impression (2)"
	options:attributes	"Attributs"
	options:dances		"Danses"
	options:templates	"Mod�les"
	options:database	"Base de donn�e"
	options:language	"Langue"

	saving				"Sauvegarde"
	saving:backup		"G�n�rer des backups (.bak.ska) lors des enregistrements"
	saving:autosave		"Sauvegarde automatique toutes les"
	saving:autosave2	"minutes (0 pour d�sactiver)"
	specialmodes		"Modes sp�ciaux"
	mode:compmgr		"compatibilit� CompMgr"
	mode:linkOCM			"liaison avec OCM"
	mode:linkOCM:DBserver	"DB Server"
	mode:linkOCM:DBuser		"DB User"
	mode:linkOCM:DBpassword "DB Password"
	mode:linkOCM:DBdatabase "DB Database"
	mode:linkOCM:server		"OCM Server"
	mode:linkOCM:id			"OCM Scrutinner ID"
	mode:linkOCM:wireless	"utilisation de PDAs"
	mode:linkOCM:DBlogin	"Login DB"
	mode:linkOCM:login		"Login OCM"
	mode:linkOCM:autologin	"Auto-Login"
	colors				"Couleurs"
	other...			"Autre ..."
	colors:finale		"Couleurs dans les finales"
	color:place			"Note correcte"
	color:placebad		"Note en conflit"
	color:exclusion		"Couples exclus (fond)"
	color:exclusion:text "Couples exclus (texte)"
	colors:rounds		"Couleurs des rounds � s�lection directe"
	color:choosengood	"Nombre de couples selectionn� correct"
	color:choosenprequalif "Couple pr�-qualifi�"
	color:choosenbad	"Pas assez ou trop de couples"
	colors:general		"Couleurs globales"
	color:competition	"Affichage du round actif"
	color:flash			"Panel ou mod�le actif"
	color:lightyellow	"Label horizontal des tableaux"
	color:lightyellow2	"Label horizontal des tableaux alternatif"
	color:yellow		"Label vertical des tableaux"
	color:lightorange	"Label horizontal des tableaux (actif)"
	color:orange		"Label vertical des tableaux (actif)"
	colors:judges		"Couleurs lors de la s�lection des juges"
	color:selected		"Juge s�lectionn�"
	color:notselected	"Juge non s�lectionn�"
	color:colselected	"Round s�lectionn�"
	colors:printing		"Couleurs pour l'impression"
	color:print:dark	"couleur titre des tableaux"
	color:print:light	"couleur colonnes des tableaux"
	colors:competition	"Couleurs des comp�titions"
	color:activeCompetition	  "Comp�tition active"
	color:finishedCompetition "Comp�tition ternim�e"
	color:activeDance	"Danse active"
	color:finishedDance	"Danse ternim�e"

	names:rounds		"Afficher le noms des juges dans les rounds"
	names:finale		"Afficher le noms des juges dans la finale"
	explain:finale		"Afficher le calcul des classements dans les finales"
	keyboard:toggleling	"Permettre une bascule de s�lection par double saisie"
	showNewAtSartup		"Afficher la boite de cr�ation rapide au d�marrage"
	explicitNames		"Utiliser des noms explicites par d�faut"
	explain:ten			"Afficher les r�gles 10&11 pour classement dix-danses"
	tip:name			"Afficher le nom du couple ou juge en plus de la comp�tition dans les bulles d'aides lors de la saisie"
	judges:button:compact "Dans les juges, un seul bouton pour une comp�tition dix danses"

	detailLevel1		"Niveau de d�tail (g�n�ral)"
	detail:color		"couleurs dans les tableaux"
	detail:comment		"commentaire associ�"
	detail:listCouples	"liste des couples"
	detail:listJudges	"liste des juges"
	detail:order		"trier rounds par total des marks"
	detail:sign			"signatures en bas de page"
	detail:useLetters	"lettres des judges au lieu des X"
	detail:useAverage	"place moyenne au lieu intervalle X-Y"
	detailLevel2		"Niveau de d�tail (rounds & finale)"
	detail:judges		"noms des juges (round)"
	detail:judgesResult	"noms des juges (finale)"
	detail:couplesResult "noms des couples (finale)"
	detail:useSmallFont	"petite fonte pour couples & juges"
	detail:explain		"explications (r�gles 10 & 11)"
	detail:place		"place des premiers couples"
	detail:place:nb		"couples � marquer"
	format				"Format"
	graphic				"graphique"
	text				"texte"
	preview				"Aper�u avant impression"
	paper				"Taille du papier"
	margins				"Marges"
	margin:left			"Gauche"
	margin:right		"Droite"
	margin:bottom		"Haut"
	margin:top			"Bas"
	margin:text			"Pour une page en portrait (les marges sont invers�es pour un paysage)"
	marksSheetsMode		"Mode des feuilles de marks"
	layout				"Mise en page"
	formatting			"Format des en-t�tes"
	formatRestore		"Restaurer les valeurs par d�faut"
	format:header		"En-t�te principal, ligne"
	format:general		"Ligne g�n�rique"
	format:marksheet:portrait:header "En-t�te feuille des juges, portrait, ligne"
	format:marksheet:portrait:footer "Pied de page feuille des juges, portrait"
	format:marksheet:landscape:data "Donn�es dans le bandeau, paysage, ligne"
	format:marksheet:landscape:header "En-t�te feuille des juges, paysage, ligne"
	format:block:idsf:report "Bloc d'information, rapport IDSF"

	print:title			"Titre"
	print:subtitle		"Sous-titre"
	print:date			"Date"
	print:comment		"Commentaires"
	print:normal		"Normal"
	print:bold			"Gras"
	print:subscript		"Exposant"
	print:small			"Petit texte"
	print:smallbold		"Petit text gras"
	font:folder			"Grand"
	font:title			"Moyen"
	font:date			"Petit"

	attributes:age		"Classe d'age"
	attributes:agemin	"Age minimum"
	attributes:agemax	"Age maximum"
	attributes:ageext	"Age extra info"
	attributes:type		"Discipline"
	attributes:level	"Niveau"
	generateFolderName	"G�n�rer le nom de la comp�tition"
	folderNaming		"Motif pour la g�n�ration du nom de la comp�tition"

	dances:new			"Nouvelle danse ..."
	dances:edit			"Editer la danse ..."
	dances:separator	"Ajouter un s�parateur"
	dances:help			{"<Haut>/<Bas>:" blue \
						"\tS�lectionne une danse\n" normal \
						"<Shift>+<Haut>/<Bas>:" blue \
						"\tD�place la danse\n" normal \
						"<Ins>/<Suppr>:" blue \
						"\tInsert une nouvelle danse / supprime la danse" normal}

	templates:danses	"Mod�les pour les ensembles de danses"
	templates:file		"Fichier par d�faut pour les mod�les de comp�titions"

	db:activate			"Activation"
	db:activate:couples	"Activer la compl�tion pour les couples & les �coles"
	db:activate:judges	"Activer la compl�tion pour les juges"
	db:file				"Fichier"
	db:filename			"Nom du fichier"
	db:help				{"Pour modifier la base de donn�es, ouvrir le fichier dans un �diteur de texte. Les donn�es sont stock�es dans trois variables nomm�es " normal \
						"judges" blue " pour les juges, " normal \
						"couples" blue " pour les couples et " normal \
						"schools" blue " pour les �coles/clubs.\n\n" normal \
						"Les donn�es sont sauv�es par ordre alphab�tique pour faciliter l'�dition. Toutefois, l'ordre des donn�es dans le fichier n'a aucune importance.\n\n" normal \
						"Les fonctions Export/Import permettent d'enregistrer les donn�es dans des colonnes. Elles peuvent �tre modifi�es sous Excel et ensuite importer.\n\n" normal}
	db:export			"Exporter vers le presse-papier (Copier)"
	db:import			"Importer depuis le presse-papier (Coller)"

	language:language	"Langue"
	language:new		"Nouveau ..."
	language:edit		"Edition"
	language:help		{"Alt+Haut/Bas:" blue \
						"\tS�lection de l'�l�ment � traduire pr�c�dent/suivant\n" normal}
						

	license:demo		"Version d'�valuation"
	license:registred	"Enregistr� pour"
	license:expiry		"Valide jusqu'au"
	license:id			"Num�ro d'identification"
	license:maxallowed	"Valide jusqu'� version"


	result:simple		"R�sultats globaux"
	result:extended:place "D�tail par place"
	result:extended:couple "D�tail par couple"
	result:computing	"Calcul des r�sultats"
	result:computing:msg "Couples trait�s :"


	prt:general			"Ev�nement"
	prt:competitions	"Comp�titions"
	prt:index			"Accueil"
	prt:rounds			"Rounds"
	prt:round			"Round"
	prt:dances			"Danses"
	prt:dance			"Danse"
	prt:produced		"(c)"
	prt:place			"Place"
	prt:placeFrom		"Place de"
	prt:placeTo			"�"
	prt:place:short		"Plc"
	prt:couple			"Cple"
	prt:final			"Classement final"
	prt:final:dances	"Classement par danse"
	prt:total			"Total"
	prt:selected		"%1$d couples s�lectionn�s pour %4$s (%2$d demand�s)"
	prt:selectedPrequalif "%1$d couples s�lectionn�s pour %4$s (%2$d demand�s, %3$d pr�qualifi�s)"
	prt:explainPrequalif "(%1$d pr�qualifi�s, %2$d couples sur %5$d pour '%6$s')"
	prt:explainPrequalifSplit "(%1$d pr�qualifi�s, %2$d+%3$d=%4$d couples sur %5$d pour '%6$s')"
	prt:rule			"R�gle"
	prt:majority		"majorit�"
	prt:explainRule		"Application de la r�gle $nb"
	prt:keep			"$nb repris"
	prt:selNotDone		"s�lection non effectu�e"
	prt:result			"R�sultat"
	prt:resultShort		"Re"
	prt:results			"R�sultats"
	prt:resultsFinale	"R�sultats de la finale"
	prt:statistics		"Statistiques"
	prt:set				"Qualifi�s"
	prt:headerTot		"Tot. Repris"
	prt:roundMaxi		"Meilleur classement atteint par les couples"
	prt:name			"Nom"
	prt:school			"Ecole/Club"
	prt:country			"Pays"
	prt:page			"Page"
	prt:placeAbbrev		"P"
	prt:tot				"Tot."
	prt:class			"Class."
	prt:rules			"R�gles"
	prt:yes				"oui"
	prt:keepLabel		"Rep."
	prt:judges			"Juges"
	prt:couples			"Couples"
	prt:couples2		"couples"
	prt:prequalified	"Pr�qualifi�s"
	prt:prequalified2	"pr�qualifi�s"
	prt:couplesNb		"N�"
	prt:scrutineer		"Scrutineer"
	prt:chairman		"Chairman"
	prt:panel			"Panel"
	prt:panels			"Liste des panels de juges"
	prt:enrollment:couples "Participation des couples aux comp�titions"
	prt:enrollment:judges "Participation des juges aux comp�titions"
	prt:competitions:list "Liste des comp�titions"
	prt:summary			"Bilan de la comp�tition"
	prt:summaryFor		"Bilan pour"
	prt:round			"Rnd"
	prt:heats			"Liste des heats pour le round"
	prt:Heat			"Heat"
	prt:sign			"Signature"
	prt:skipped			"non dans�e"
	prt:sumInFinale		"Somme en finale"
	prt:idsf:report		"Rapport de la comp�tition"
	prt:idsf:table		"Tableau des r�sultats"

	prt:nbcouples		"Nombres de couples en comp�tition"
	prt:couplesRegistered "couples enregistr�s"
	prt:judgesRegistered "juges enregistr�s"
	prt:notAvailable	"Non disponible"
	prt:dataFor3S		"Fichier informatique pour le logiciel 3S"
	prt:siteArchive		"Archive ZIP du site Web"


	tip:new				"Nouveau fichier (Ctrl+N)"
	tip:open			"Ouvrir fichier (Ctrl+O)"
	tip:save			"Sauver fichier (Ctrl+S)"
	tip:print			"Imprimer (Ctrl+P)"
	tip:options			"R�glage des pr�f�rences"
	tip:event			"D�finition et gestion des couples et des juges (Ctrl+D)"
	tip:comp:new		"Nouvelle comp�tition (Ctrl+C)\nClick-droit pour les  mod�les de comp�titions"
	tip:comp:delete		"Suppression comp�tition (Ctrl+Suppr)"
	tip:comp:moveup		"D�placer la comp�tition vers le haut (Ctrl+Up)"
	tip:comp:movedown	"D�placer la comp�tition vers le bas (Ctrl+Down)"
	tip:print:result1	"Impression DIRECTE de la liste des heats pour le round suivant"
	tip:print:result2	"Impression DIRECTE de la liste des heats et des feuilles pour les juges pour le round suivant"
	tip:print:result3	"Impression DIRECTE de la liste des couples & des juges pour le round suivant"


	dateFormat			"%d %B %Y"
	months				{Janvier F�vrier Mars Avril Mai Juin Juillet Ao�t Septembre Octobre Novembre D�cembre}


	help:rounds 		"Rappel des limites impos�es par la FFDS :
	8 couples	-->	1/2 finale
	15 couples	-->	1/4 finale
	29 couples	-->	1/8 finale
	57 couples	-->	1/16 finale
	113 couples	-->	1/32 finale"
}
