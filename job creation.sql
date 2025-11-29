USE msdb;
GO

-- 1. Nettoyage : On supprime le job s'il existe déjà pour éviter les erreurs
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'job1')
    EXEC msdb.dbo.sp_delete_job @job_name=N'job1', @delete_unused_schedule=1;
GO

-- 2. Création du Job principal
-- On définit ici le nom et le niveau de notification (email)
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
    EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'job1', 
        @enabled=1, 
        @notify_level_eventlog=0, 
        @notify_level_email=3, -- 3 = Envoyer un mail si Succès ou Échec (Condition étape 11)
        @notify_email_operator_name=N'Administrateur', -- Nom de l'opérateur créé
        @owner_login_name=N'sa', 
        @category_name=N'[Uncategorized (Local)]', 
        @job_id = @jobId OUTPUT

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

-- 3. Création de l'Étape (Step) : Lancer SSIS
-- ⚠️ IMPORTANT : Remplacez le chemin ci-dessous par VOTRE chemin réel !
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Lancer Package SSIS', 
        @step_id=1, 
        @cmdexec_success_code=0, 
        @on_success_action=1, 
        @on_success_step_id=0, 
        @on_fail_action=2, 
        @on_fail_step_id=0, 
        @retry_attempts=0, 
        @retry_interval=0, 
        @os_run_priority=0, 
        @command=N'dtexec /F "C:\Users\YOGA\Desktop\MonProjet\Package.dtsx"', -
        @flags=0

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

-- 4. Création du Planning (Schedule) : Chaque 1 Heure
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1

EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Planning Horaire', 
        @enabled=1, 
        @freq_type=4, -- 4 = Quotidien (Daily)
        @freq_interval=1, -- Tous les 1 jours
        @freq_subday_type=8, -- 8 = Heures (Hours)
        @freq_subday_interval=1, -- Toutes les 1 heures
        @active_start_date=20251124, 
        @active_start_time=0, 
        @schedule_uid=N'fac13030-22c6-4309-8051-289520593437' -- (ID aléatoire)

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

-- 5. Validation finale
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

COMMIT TRANSACTION
GOTO EndSave

QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO