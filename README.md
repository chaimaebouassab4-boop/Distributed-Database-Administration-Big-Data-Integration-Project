
Projet académique réalisé dans le cadre du cours **"Administration des Bases de Données Distribuées et Clusters Big Data"** sous la supervision du **Prof. C. EL AMRANI**.

Ce projet consiste à créer un environnement de bases de données distribuées intégrant **quatre systèmes de gestion de bases de données** (SQL Server, Oracle, DB2, PostgreSQL) avec un pipeline ETL automatisé pour l'intégration de données multi-sources.


## 🎯 Objectifs Pédagogiques

1. Maîtriser l'administration de bases de données distribuées sur plusieurs SGBD
2. Configurer un domaine Active Directory pour l'authentification centralisée
3. Implémenter des processus ETL avec SQL Server Integration Services (SSIS)
4. Automatiser l'exécution de tâches avec SQL Server Agent
5. Gérer la connectivité réseau entre machines virtuelles
6. Intégrer des sources de données hétérogènes (SQL Server, Oracle, DB2, PostgreSQL)

---

## 🏗️ Architecture Technique

### Infrastructure Virtuelle (VirtualBox)

```
┌────────────────────────────────────────────────────────────┐
│               DOMAINE: [NomDeFamille].local                │
│                                                            │
│  ┌─────────────────────┐      ┌────────────────────────┐  │
│  │  VM Windows Server  │      │  VM Windows 10/11      │  │
│  │  ─────────────────  │      │  ──────────────────    │  │
│  │  • Active Directory │◄─────┤  • Client du domaine   │  │
│  │  • DNS Server       │      │  • SSMS                │  │
│  │  • SQL Server 2019  │      │  • Connexion distante  │  │
│  │    - BD1, Table1    │      │                        │  │
│  └─────────────────────┘      └────────────────────────┘  │
│                                                            │
│  ┌─────────────────────┐                                  │
│  │  VM Ubuntu Server   │      Réseau : NAT Network        │
│  │  ─────────────────  │      Authentification : Windows  │
│  │  • Oracle XE 21c    │                                  │
│  │    - Table2         │                                  │
│  └─────────────────────┘                                  │
└────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│           MACHINE PHYSIQUE (Non virtualisée)             │
│  ────────────────────────────────────────────────────    │
│  • Windows 10/11                                         │
│  • DB2 Community Edition → BD2, Table3                   │
│  • PostgreSQL → BD4                                      │
│  • SQL Server (local) → BD3                              │
│  • SSIS Package (package1)                               │
│  • SQL Server Agent → job1                               │
└──────────────────────────────────────────────────────────┘
```

### Flux de Données ETL

```
┌─────────────────────────────────────────────────────┐
│              SSIS Package (package1)                │
│                                                     │
│  SOURCES (Extract):                                 │
│  ├─ Table1 (SQL Server/BD1) - VM Windows Server    │
│  ├─ Table2 (Oracle XE)      - VM Ubuntu            │
│  └─ Table3 (DB2/BD2)        - Machine physique     │
│                                                     │
│  DESTINATIONS (Load):                               │
│  ├─ BD3 (SQL Server local)  - Machine physique     │
│  ├─ Data1.txt (fichier CSV) - Machine physique     │
│  └─ BD4 (PostgreSQL local)  - Machine physique     │
│                                                     │
│  PLANIFICATION:                                     │
│  └─ job1 : Exécution toutes les 1 heure            │
│     └─ Notification email à l'administrateur       │
└─────────────────────────────────────────────────────┘
```

---

## 📝 Étapes de Réalisation

### Étape 1 : Installation Windows Server (VM VirtualBox)
- Création d'une machine virtuelle
- Installation de Windows Server 2019/2022
- Configuration réseau (NAT Network)

### Étape 2 : Configuration Active Directory
- Promotion du serveur en contrôleur de domaine
- Création du domaine : `[NomDeFamille].local`
- Création d'un utilisateur avec prénom du groupe
- Configuration du service DNS

### Étape 3 : Installation SQL Server
- Installation de SQL Server 2019 Express dans Windows Server
- Configuration de l'authentification Windows
- Installation de SQL Server Management Studio (SSMS)

### Étape 4 : Attribution des accès SQL Server
- Ajout de l'utilisateur du domaine comme Login SQL Server
- Configuration des permissions d'accès

### Étape 5 : Autorisation de création de bases de données
- Attribution du rôle serveur `dbcreator` à l'utilisateur
- Vérification des permissions

### Étape 6 : Installation Windows 10/11 (VM VirtualBox)
- Création d'une deuxième machine virtuelle
- Installation de Windows 10 ou 11
- Configuration réseau identique au serveur

### Étape 7 : Jonction au domaine et création de BD1
- Connexion de Windows 10/11 au domaine Active Directory
- Authentification avec le compte utilisateur du domaine
- Connexion distante à SQL Server via SSMS
- Création de la base `BD1` et de `Table1` (id INT, nom VARCHAR(20))
- Insertion de données de test

### Étape 8 : Installation Oracle Database (VM Ubuntu)
- Création d'une machine virtuelle Ubuntu Server
- Installation d'Oracle Database Express Edition 21c
- Création de `Table2` (ref INT, article VARCHAR)
- Insertion de lignes d'enregistrement

### Étape 9 : Installation DB2 (Machine Physique)
- Installation de DB2 Community Edition sur la machine physique Windows
- Création de la base de données `BD2`
- Création de `Table3` (num INT, lib VARCHAR)
- Insertion de données de test

### Étape 10 : Développement du package SSIS
- Création du package `package1` avec SQL Server Data Tools (SSDT)
- Configuration des sources de données :
  - Connexion à SQL Server (Table1)
  - Connexion à Oracle (Table2)
  - Connexion à DB2 (Table3)
- Configuration des destinations :
  - Base de données `BD3` (SQL Server local)
  - Fichier texte `Data1.txt`
  - Base de données `BD4` (PostgreSQL local)
- Tests et validation du package

### Étape 11 : Automatisation avec SQL Server Agent
- Création du job `job1` dans SQL Server Agent
- Configuration de l'exécution du package SSIS
- Planification : exécution toutes les 1 heure
- Configuration des notifications par email à l'administrateur
- Tests avec une fréquence de 10 secondes

---

## 💻 Technologies Utilisées

| Composant | Version | Rôle |
|-----------|---------|------|
| **VirtualBox** | 7.0+ | Plateforme de virtualisation |
| **Windows Server** | 2019/2022 | Contrôleur de domaine, serveur SQL |
| **Windows 10/11** | Latest | Client du domaine, poste de travail |
| **Ubuntu Server** | 22.04 LTS | Serveur Oracle Database |
| **Active Directory** | Windows Server | Authentification centralisée |
| **SQL Server** | 2019 Express | SGBD principal, ETL, automatisation |
| **Oracle Database XE** | 21c | Source de données distribuée |
| **DB2 Community** | Latest | Source de données distribuée |
| **PostgreSQL** | 14+ | Destination ETL supplémentaire |
| **SSIS** | SQL Server 2019 | Développement du pipeline ETL |
| **SQL Server Agent** | SQL Server 2019 | Planification et automatisation |
| **SSMS** | Latest | Administration des bases de données |

---

## 📦 Livrables du Projet
### Code Source
- ✅ Scripts SQL de création des bases et tables
- ✅ Package SSIS (fichier .dtsx)
- ✅ Scripts PowerShell de configuration
- ✅ Scripts de création du job SQL Server Agent

### Documentation
- ✅ Rapport de projet complet (PDF)
- ✅ Diagrammes d'architecture
- ✅ Captures d'écran de toutes les étapes
- ✅ Guide d'installation et de configuration
- ✅ Documentation des problèmes rencontrés et solutions

### Démonstration
- ✅ VMs fonctionnelles avec tous les composants installés
- ✅ Job SQL Server Agent planifié et fonctionnel
- ✅ Données importées dans BD3, Data1.txt et BD4
- ✅ Historique d'exécution du job

