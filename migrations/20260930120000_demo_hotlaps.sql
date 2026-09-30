-- Demo records have their own provenance: no fabricated replay or HLVC result.
-- Era slugs use URL-unreserved characters and form one non-special path segment.
ALTER TABLE era DROP CONSTRAINT era_id_check,
    ADD CONSTRAINT era_id_check CHECK (
        slug ~ '^[A-Za-z0-9._~-]+$' AND slug NOT IN ('.', '..')
    );

ALTER TABLE hotlap
    DROP CONSTRAINT hotlap_source_check,
    DROP CONSTRAINT hotlap_replay_provenance_check,
    DROP CONSTRAINT hotlap_valid_state_check,
    DROP CONSTRAINT hotlap_lifecycle_source_check,
    ADD CONSTRAINT hotlap_source_check CHECK (
        source IN ('upload', 'lfsworld_v1', 'demo')
    ),
    ADD CONSTRAINT hotlap_replay_provenance_check CHECK (
        (source = 'upload' AND spr_object_key IS NOT NULL AND fingerprint ~ '^[0-9a-f]{64}$')
        OR (source = 'lfsworld_v1' AND spr_object_key IS NULL
            AND fingerprint ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}:[1-9][0-9]*$')
        OR (source = 'demo' AND spr_object_key IS NULL AND original_filename IS NULL
            AND fingerprint LIKE 'demo:%')
    ),
    ADD CONSTRAINT hotlap_valid_state_check CHECK (
        state <> 'valid' OR (vehicle IS NOT NULL AND (
            source IN ('lfsworld_v1', 'demo')
            OR (hlvc_result_code = 1 AND finished_at IS NOT NULL)
        ))
    ),
    ADD CONSTRAINT hotlap_lifecycle_source_check CHECK (
        (source = 'upload' AND original_filename IS NOT NULL)
        OR (source IN ('lfsworld_v1', 'demo') AND state = 'valid'
            AND hlvc_result_code IS NULL AND attempt_count = 0
            AND next_attempt_at IS NULL AND started_at IS NULL AND finished_at IS NULL)
    );
