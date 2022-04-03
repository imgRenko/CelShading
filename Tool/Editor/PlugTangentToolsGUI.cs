using UnityEngine;
using System.Collections;
using UnityEditor;
using System.IO;
namespace imgRenkoRenderFrameWork
{

    [CustomEditor(typeof(PlugTangentTools))]
    public class PlugTangentToolsGUI : Editor
    {

        
        public SerializedProperty tarMesh;

        public SerializedProperty tangentsList;


     
        private void OnEnable()
        {
            tarMesh = serializedObject.FindProperty("tarMesh");
            tangentsList = serializedObject.FindProperty("tangentsList");
            
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();
            EditorGUILayout.PropertyField(tarMesh, new GUIContent("tarMesh"));
            EditorGUILayout.PropertyField(tangentsList, new GUIContent("tangentsList"));
            if (GUI.changed)
            {
                EditorUtility.SetDirty(target);
            }
            
            
            if (GUILayout.Button("Bake Tangents")) {
                PlugTangentTools Tool = (PlugTangentTools)target;
                Tool.tarMesh = (GameObject)tarMesh.objectReferenceValue;
                Tool.WirteAverageNormalToTangentToos();


            }
            serializedObject.ApplyModifiedProperties();
        }
    }
}