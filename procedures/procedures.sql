CREATE OR REPLACE PROCEDURE modificar_rol_usuario(p_id_usuario INTEGER, p_id_rol INTEGER) LANGUAGE plpgsql AS $$ BEGIN IF NOT EXISTS (
        SELECT 1
        FROM usuario
        WHERE usar_id = p_id_usuario
    ) THEN RAISE EXCEPTION 'El usuario con ID % no existe.',
    p_id_usuario;
END IF;
IF NOT EXISTS (
    SELECT 1
    FROM rol
    WHERE r_id = p_id_rol
) THEN RAISE EXCEPTION 'El rol con ID % no existe.',
p_id_rol;
END IF;
UPDATE usuario
SET fk_r_usar = p_id_rol
WHERE usar_id = p_id_usuario;
RAISE NOTICE 'Rol modificado exitosamente para el usuario %',
p_id_usuario;
END;
$$;
CREATE OR REPLACE PROCEDURE crear_rol(p_nombre VARCHAR, p_descripcion VARCHAR) LANGUAGE plpgsql AS $$ BEGIN IF p_nombre IS NULL
    OR btrim(p_nombre) = '' THEN RAISE EXCEPTION 'El nombre del rol no puede estar vacío.';
END IF;
IF p_descripcion IS NULL
OR btrim(p_descripcion) = '' THEN RAISE EXCEPTION 'La descripción del rol no puede estar vacía.';
END IF;
IF EXISTS (
    SELECT 1
    FROM rol
    WHERE lower(r_nombre) = lower(btrim(p_nombre))
) THEN RAISE EXCEPTION 'Ya existe un rol con el nombre "%".',
btrim(p_nombre);
END IF;
INSERT INTO rol (r_nombre, r_descripcion)
VALUES (btrim(p_nombre), btrim(p_descripcion));
RAISE NOTICE 'Rol "%" creado exitosamente.',
btrim(p_nombre);
END;
$$;
CREATE OR REPLACE PROCEDURE eliminar_rol(p_id_rol INTEGER) LANGUAGE plpgsql AS $$
DECLARE v_nombre_rol VARCHAR(255);
v_usuarios_asignados INTEGER;
v_permisos_removidos INTEGER;
BEGIN -- 1. El rol debe existir (de paso obtenemos su nombre para los mensajes).
SELECT r_nombre INTO v_nombre_rol
FROM rol
WHERE r_id = p_id_rol;
IF NOT FOUND THEN RAISE EXCEPTION 'El rol con ID % no existe.',
p_id_rol;
END IF;
-- No debe estar asignado a ningún usuario.
SELECT COUNT(*) INTO v_usuarios_asignados
FROM usuario
WHERE fk_r_usar = p_id_rol;
IF v_usuarios_asignados > 0 THEN RAISE EXCEPTION 'No se puede eliminar el rol "%" (ID %): está asignado a % usuario(s).',
v_nombre_rol,
p_id_rol,
v_usuarios_asignados;
END IF;
-- Limpiar permisos asociados al rol (evita violar la FK rol_permiso -> rol).
DELETE FROM rol_permiso
WHERE fk_r_rp = p_id_rol;
GET DIAGNOSTICS v_permisos_removidos = ROW_COUNT;
DELETE FROM rol
WHERE r_id = p_id_rol;
RAISE NOTICE 'Rol "%" (ID %) eliminado. Se removieron % asociación(es) de permisos.',
v_nombre_rol,
p_id_rol,
v_permisos_removidos;
END;
$$;
CREATE OR REPLACE PROCEDURE agregar_permiso_rol(p_id_rol INTEGER, p_id_permiso INTEGER) LANGUAGE plpgsql AS $$ BEGIN IF NOT EXISTS (
        SELECT 1
        FROM rol
        WHERE r_id = p_id_rol
    ) THEN RAISE EXCEPTION 'El rol con ID % no existe.',
    p_id_rol;
END IF;
IF NOT EXISTS (
    SELECT 1
    FROM permiso
    WHERE pms_id = p_id_permiso
) THEN RAISE EXCEPTION 'El permiso con ID % no existe.',
p_id_permiso;
END IF;
IF EXISTS (
    SELECT 1
    FROM rol_permiso
    WHERE fk_r_rp = p_id_rol
        AND fk_pms_rp = p_id_permiso
) THEN RAISE EXCEPTION 'El rol % ya tiene asignado el permiso %.',
p_id_rol,
p_id_permiso;
END IF;
INSERT INTO rol_permiso (fk_r_rp, fk_pms_rp)
VALUES (p_id_rol, p_id_permiso);
RAISE NOTICE 'Permiso % asignado al rol % exitosamente.',
p_id_permiso,
p_id_rol;
END;
$$;
CREATE OR REPLACE PROCEDURE eliminar_permiso_rol(p_id_rol INTEGER, p_id_permiso INTEGER) LANGUAGE plpgsql AS $$
DECLARE v_filas_afectadas INTEGER;
BEGIN IF NOT EXISTS (
    SELECT 1
    FROM rol
    WHERE r_id = p_id_rol
) THEN RAISE EXCEPTION 'El rol con ID % no existe.',
p_id_rol;
END IF;
IF NOT EXISTS (
    SELECT 1
    FROM permiso
    WHERE pms_id = p_id_permiso
) THEN RAISE EXCEPTION 'El permiso con ID % no existe.',
p_id_permiso;
END IF;
DELETE FROM rol_permiso
WHERE fk_r_rp = p_id_rol
    AND fk_pms_rp = p_id_permiso;
GET DIAGNOSTICS v_filas_afectadas = ROW_COUNT;
IF v_filas_afectadas = 0 THEN RAISE EXCEPTION 'El rol % no tiene asignado el permiso %; no hay nada que eliminar.',
p_id_rol,
p_id_permiso;
END IF;
RAISE NOTICE 'Permiso % removido del rol % exitosamente.',
p_id_permiso,
p_id_rol;
END;
$$;