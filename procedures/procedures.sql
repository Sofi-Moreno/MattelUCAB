CREATE OR REPLACE PROCEDURE modificar_rol_usuario(p_id_usuario INTEGER, p_id_rol INTEGER) LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM usuario
        WHERE usar_id = p_id_usuario
    ) THEN
        RAISE EXCEPTION 'El usuario con ID % no existe.', p_id_usuario;
    END IF;
    IF NOT EXISTS (
        SELECT 1
        FROM rol
        WHERE r_id = p_id_rol
    ) THEN
        RAISE EXCEPTION 'El rol con ID % no existe.', p_id_rol;
    END IF;
    UPDATE usuario
    SET fk_r_usar = p_id_rol
    WHERE usar_id = p_id_usuario;

    RAISE NOTICE 'Rol modificado exitosamente para el usuario %', p_id_usuario;
END;
$$;

