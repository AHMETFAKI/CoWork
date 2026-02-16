const admin = require('firebase-admin');
const functions = require('firebase-functions');

admin.initializeApp();

function asString(value) {
  if (typeof value !== 'string') return '';
  return value.trim();
}

exports.createUserWithProfile = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Sign-in required.');
  }

  const actorUid = context.auth.uid;
  const actorSnap = await admin.firestore().doc(`users/${actorUid}`).get();
  const actorRole = actorSnap.exists ? actorSnap.data().role : null;
  if (actorRole !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Admin only.');
  }

  const fullName = asString(data?.full_name);
  const email = asString(data?.email);
  const password = asString(data?.password);
  const role = asString(data?.role);
  const departmentId = asString(data?.department_id);
  const phone = asString(data?.phone);
  const isActive = typeof data?.is_active === 'boolean' ? data.is_active : true;
  const setDeptManager = data?.set_dept_manager === true;

  if (!fullName || !email || !password) {
    throw new functions.https.HttpsError('invalid-argument', 'full_name, email, password are required.');
  }
  if (password.length < 6) {
    throw new functions.https.HttpsError('invalid-argument', 'Password must be at least 6 characters.');
  }
  if (!['admin', 'manager', 'employee'].includes(role)) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid role.');
  }
  if (role !== 'admin' && !departmentId) {
    throw new functions.https.HttpsError('invalid-argument', 'department_id required for this role.');
  }

  let userRecord;
  try {
    userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: fullName,
      disabled: !isActive,
    });
  } catch (err) {
    const msg = err?.message ?? '';
    if (msg.includes('email address is already in use')) {
      userRecord = await admin.auth().getUserByEmail(email);
    } else {
      throw new functions.https.HttpsError('internal', `Auth create failed: ${msg || err}`);
    }
  }

  const uid = userRecord.uid;
  const existingProfile = await admin.firestore().doc(`users/${uid}`).get();
  if (existingProfile.exists) {
    throw new functions.https.HttpsError('already-exists', 'User profile already exists for this email.');
  }
  try {
    let managerId = null;
    if (role === 'manager') {
      managerId = actorUid;
    } else if (role === 'employee' && departmentId) {
      const deptSnap = await admin.firestore().doc(`departments/${departmentId}`).get();
      if (deptSnap.exists) {
        managerId = deptSnap.data().manager_id || null;
      }
    }

    const userDoc = {
      full_name: fullName,
      email,
      role,
      department_id: role === 'admin' ? null : departmentId,
      manager_id: managerId,
      created_by_user_id: actorUid,
      phone,
      is_active: isActive,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
      last_login_at: null,
    };

    const batch = admin.firestore().batch();
    batch.set(admin.firestore().doc(`users/${uid}`), userDoc, { merge: true });

    if (role === 'manager' && setDeptManager && departmentId) {
      batch.set(
        admin.firestore().doc(`departments/${departmentId}`),
        {
          manager_id: uid,
          updated_at: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }

    const logRef = admin.firestore().collection('audit_logs').doc();
    batch.set(logRef, {
      actor_user_id: actorUid,
      department_id: departmentId || null,
      entity_type: 'user',
      entity_id: uid,
      action: 'create_user',
      metadata_json: JSON.stringify({
        role,
        email,
        set_dept_manager: setDeptManager,
      }),
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    await batch.commit();
  } catch (err) {
    // Only delete Auth user if we just created it in this call
    if (userRecord?.metadata?.creationTime && userRecord.metadata.lastSignInTime == null) {
      await admin.auth().deleteUser(uid);
    }
    throw new functions.https.HttpsError('internal', `Profile create failed: ${err?.message ?? err}`);
  }

  return { uid };
});
