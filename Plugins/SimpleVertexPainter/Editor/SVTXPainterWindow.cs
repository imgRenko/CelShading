using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using SVTXPainter;

namespace SVTXPainterEditor
{
    public class SVTXPainterWindow : EditorWindow
    {
        #region Variables
        private GUIStyle titleStyle;
        private bool allowPainting = false;
        private bool changingBrushValue = false;
        private bool allowSelect = false;
        private bool isPainting = false;
        private bool isRecord = false;
        private bool pickColor = false;
        private bool viewCurrent = false;


        private bool displayingPoint = false;
        private bool displayingFrontPoint = true;
        private bool protectOutlineWidth = true;

        private bool dataChanged = false;

        private Vector2 mousePos = Vector2.zero;
        private Vector2 lastMousePos = Vector2.zero;
        private RaycastHit curHit;
        private Vector2 scrollView = Vector2.zero;


        private float brushSize = 0.1f;
        private float brushOpacity = 1f;
        private float brushFalloff = 0.1f;

        private Color brushColor;
        private float brushIntensity;

        private const float MinBrushSize = 0.001f;

        private const float pickColorSize = 0.005f;

        public const float MaxBrushSize = 10f;
        private string Shaders;

        private int curColorChannel = (int)PaintType.All;

        private Mesh curMesh;

        private Vector3[] curMeshVertWS;
        private Vector3[] curMeshNormWS;

 


        private SVTXObject m_target;
        private GameObject m_active;

        #endregion

        #region Main Method
        [MenuItem("Model Painter/Outline Painter")]
        public static void LauchVertexPainter()
        {
            var window = EditorWindow.GetWindow<SVTXPainterWindow>();
            window.titleContent = new GUIContent("Outline Painter");
            window.Show();
            window.OnSelectionChange();
            window.GenerateStyles();
        }

        private void OnEnable()
        {
            SceneView.duringSceneGui -= this.OnSceneGUI;
            SceneView.duringSceneGui += this.OnSceneGUI;
            if (titleStyle == null)
            {
                GenerateStyles();
            }
           
        }

        private void OnDestroy()
        {
            SceneView.duringSceneGui -= this.OnSceneGUI;
        }

        private void OnSelectionChange()
        {
            m_target = null;
            m_active = null;
            curMesh = null;
            curMeshVertWS =null;
            curMeshNormWS = null;
            if (Selection.activeGameObject != null)
            {
                m_target = Selection.activeGameObject.GetComponent<SVTXObject>();
                curMesh = SVTXPainterUtils.GetMesh(Selection.activeGameObject);
               
                if (m_target != null)
                {
                    curMeshVertWS = curMesh.vertices;
                    for (int i = 0; i < curMeshVertWS.Length; ++i)
                    {
                        curMeshVertWS[i] = m_target.transform.TransformPoint(curMeshVertWS[i]);
                    }
                    curMeshNormWS = curMesh.normals;
                    for (int i = 0; i < curMeshNormWS.Length; ++i)
                    {
                        curMeshNormWS[i] = m_target.transform.TransformPoint(curMeshNormWS[i]);
                    }
                   
                }
                var activeGameObject = Selection.activeGameObject;
                if (curMesh != null)
                {
                    m_active = activeGameObject;
                  
                }
            }
            allowSelect = (m_target == null);
           
            Repaint();
        }

        #endregion

        #region GUI Methods
        private void OnGUI()
        {
            //Header
            GUILayout.BeginHorizontal();
        //    GUILayout.Box("Simple Vertex Painter", titleStyle, GUILayout.Height(20), GUILayout.ExpandWidth(true));
            GUILayout.EndHorizontal();
            scrollView = GUILayout.BeginScrollView(scrollView);
            //Body
            GUILayout.BeginVertical(GUI.skin.box);
           

            if (m_target != null)
            {
                if (!m_target.isActiveAndEnabled)
                {
                    EditorGUILayout.LabelField("(Enable " + m_target.name + " to show Simple Vertex Painter)");
                    
                }
                else
                {
                    GUILayout.Label("Switch", EditorStyles.boldLabel);
                    //bool lastAP = allowPainting;
                    allowPainting = GUILayout.Toggle(allowPainting, "Paint Mode");
                    EditorGUILayout.Space(10);
                    if (allowPainting)
                    {
                        GUILayout.Label("Options", EditorStyles.boldLabel);
                        displayingPoint = GUILayout.Toggle(displayingPoint, "Displaying Effecting Point");
                        displayingFrontPoint = GUILayout.Toggle(displayingFrontPoint, "Displaying Effecting Front Point");
                        protectOutlineWidth = GUILayout.Toggle(protectOutlineWidth, "Protect Outline Width");
                        pickColor = GUILayout.Toggle(pickColor, "Pick Color");
                      
                        if (allowPainting)
                        {
                            //Selection.activeGameObject = null;
                            Tools.current = Tool.None;
                        }
                        EditorGUILayout.Space(10);
                        GUILayout.Label("You need to click it again before you select another object.", EditorStyles.helpBox);
                        string buttonTitle = viewCurrent ? "Hide Preview" : "View Current";
                       
                        if (GUILayout.Button(buttonTitle) && curMesh != null)
                        {
                            SwitchViewerState();
                        }

                    }
                    EditorGUILayout.Space(10);
                    GUILayout.Label("Brush Settings", EditorStyles.boldLabel);
                    GUILayout.BeginHorizontal();
                    GUILayout.Label("Paint Type:", GUILayout.Width(90));
                    string[] channelName = { "OutlineColor", "OutlineColor-R", "OutlineColor-G", "OutlineColor-B","OutlineWidth" };
                    int[] channelIds = { 0, 1, 2, 3, 4 };
                    curColorChannel = EditorGUILayout.IntPopup(curColorChannel, channelName, channelIds, GUILayout.Width(150));
                    GUILayout.EndHorizontal();
                    GUILayout.BeginHorizontal();
                    if (curColorChannel == (int)PaintType.All)
                    {
                        brushColor = EditorGUILayout.ColorField("Brush Color:", brushColor);
                    }
                    else
                    {
                        brushIntensity = EditorGUILayout.Slider("Intensity:", brushIntensity, 0, 2);
                    }
                    if (GUILayout.Button("Fill"))
                    {
                        FillVertexColor();
                    }
                    GUILayout.EndHorizontal();
                    brushSize = EditorGUILayout.Slider("Brush Size:", brushSize, MinBrushSize, MaxBrushSize);
                    brushOpacity = EditorGUILayout.Slider("Brush Opacity:", brushOpacity, 0, 1);
                    brushFalloff = EditorGUILayout.Slider("Brush Falloff:", brushFalloff, MinBrushSize, brushSize);

                    EditorGUILayout.Space(10);
                    GUILayout.Label("Resource Manager", EditorStyles.boldLabel);
                    if (GUILayout.Button("Export .asset file") && curMesh != null)
                    {
                        string path = EditorUtility.SaveFilePanel("Export .asset file", "Assets", SVTXPainterUtils.SanitizeForFileName(curMesh.name), "asset");
                        if (path.Length > 0)
                        {
                            var dataPath = Application.dataPath;
                            if (!path.StartsWith(dataPath))
                            {
                                Debug.LogError("Invalid path: Path must be under " + dataPath);
                            }
                            else
                            {
                                path = path.Replace(dataPath, "Assets");
                                AssetDatabase.CreateAsset(Instantiate(curMesh), path);
                                dataChanged = false;
                                Debug.Log("Asset exported: " + path);
                            }
                        }
                    }

                    if (GUILayout.Button("Load .asset file") && curMesh != null)
                    {
                        string path = EditorUtility.OpenFilePanel("Load .asset file", "Assets", "asset");
                        if (path.Length > 0)
                        {
                            var dataPath = Application.dataPath;
                            if (!path.StartsWith(dataPath))
                            {
                                Debug.LogError("Invalid path: Path must be under " + dataPath);
                            }
                            else
                            {
                                path = path.Replace(dataPath, "Assets");
                                Mesh meshData = AssetDatabase.LoadAssetAtPath<Mesh>(path);
                                if (m_target && m_active)
                                {
                                    curMesh = SVTXPainterUtils.GetMesh(m_active);
                                    if (curMesh)
                                    {
                                        curMesh.colors = meshData.colors;
                                       // curMesh.
                                    }
                                }
                                Debug.Log("Asset Loaded: " + path);
                            }
                        }
                    }
                    EditorGUILayout.Space(10);
                    GUILayout.Label("Brush Pre", EditorStyles.boldLabel);
                    if (GUILayout.Button("Load Brush Pre") && curMesh != null)
                    { 
                    }
                        EditorGUILayout.Space(10);
                    GUILayout.Label("Infomation", EditorStyles.boldLabel);
                    if (curMesh != null && dataChanged) {
                        GUILayout.Label("Datas have been changed, If you don not save them before starting gameing, these datas will be loss.", EditorStyles.helpBox);
                    }
                    if (curMesh != null && m_target.prefebInGame == null)
                    {
                        GUILayout.Label("You can save these color datas to your Assets folder, and add refs about them in SVTX Object Script param. Or you will lose these changes after closing editor or changing the scene.", EditorStyles.helpBox);
                    }


                    //Footer
                    GUILayout.Label("Key Z:Turn on or off\nRight mouse button:Paint\nRight mouse button+Shift:Opacity\nRight mouse button+Ctrl:Size\nRight mouse button+Shift+Ctrl:Falloff", EditorStyles.helpBox);
                    GUILayout.Label("If you paint on the model, but it has not changed. Please check the paint tool params settings.", EditorStyles.helpBox);
                    Repaint();
                }
            }
            else if (m_active != null)
            {
                if (GUILayout.Button("Add SVTX Object to " + m_active.name))
                {
                    m_active.AddComponent<SVTXObject>();
                    OnSelectionChange();
                }
            }
            else
            {
                EditorGUILayout.LabelField("Please select a mesh or skinnedmesh.");
            }
            GUILayout.EndVertical();
            GUILayout.EndScrollView();
        }
        void OnSceneGUI(SceneView sceneView)
        {
            if (allowPainting)
            {
                bool isHit = false;
                if (!allowSelect)
                {
                    HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));
                }
                Ray worldRay = HandleUtility.GUIPointToWorldRay(mousePos);
                if (m_target != null && curMesh != null)
                {
                    Matrix4x4 mtx = m_target.transform.localToWorldMatrix;
                    RaycastHit tempHit;
                    isHit = RXLookingGlass.IntersectRayMesh(worldRay, curMesh, mtx, out tempHit);
                    if (isHit)
                    {
                        UpdatePoint();
                        if (!changingBrushValue)
                        {
                            curHit = tempHit;
                        }
                        //Debug.Log("ray cast success");
                        if (isPainting && m_target.isActiveAndEnabled && !changingBrushValue)
                        {
                            PaintVertexColor();
                        }
                    }
                }

                if (isHit || changingBrushValue)
                {

                    Handles.color = getSolidDiscColor((PaintType)curColorChannel);
                    Handles.DrawSolidDisc(curHit.point, curHit.normal, pickColor ? pickColorSize : brushSize);
                    Handles.color = getWireDiscColor((PaintType)curColorChannel);
                    Handles.DrawWireDisc(curHit.point, curHit.normal, pickColor ? pickColorSize : brushSize);
                    Handles.DrawWireDisc(curHit.point, curHit.normal, brushFalloff);



                    Handles.BeginGUI();

                    GUI.color = Color.white;
                
                    GUI.Label(new Rect(mousePos.x +10, mousePos.y -20,100,200),string.Format( "Size: {0}",brushSize), EditorStyles.toolbar);
                    Handles.EndGUI();

                }
            }
   

            ProcessInputs();

            sceneView.Repaint();

        }
        private void SwitchViewerState() {
            viewCurrent = !viewCurrent;
            Shaders = viewCurrent ? "imgRenkoRenderFramework/PainterVertexColor" : "imgRenkoURPToonShaderFramework/imgRenkoURPToonShaderFramework(Outline)";
            
                SVTXPainterUtils.SetMaterial(m_target.gameObject, Shader.Find(Shaders));


            
        }
        private void UpdatePoint() {
            if (displayingPoint)
            {

                if (m_target && m_active)
                {
                    curMesh = SVTXPainterUtils.GetMesh(m_active);
                    if (curMesh)
                    {

                        Vector3[] verts = curMesh.vertices;
                        Vector3[] norm = curMesh.normals;

                        for (int i = 0; i < verts.Length; i++)
                        {

                            Vector3 vertPos = curMeshVertWS[i];
                            Vector3 normalWS = curMeshNormWS[i];
                            if (displayingFrontPoint)
                            {
                                Vector3 VS = Camera.main.transform.position;
                                Vector3 viewPos = VS - vertPos;
                                Vector3 viewWS = VS - normalWS;
                                if (Vector3.Dot(viewPos, viewWS) < 0)
                                    continue;
                            }
                            float mag = (vertPos - curHit.point).magnitude;
                            if (mag > (pickColor ? pickColorSize : brushSize))
                            {
                                continue;
                            }
                            else
                            {

                                Handles.color = Color.black;
                             
                              Handles.DrawWireDisc(vertPos, normalWS, 0.001f);
                            }


                        }

                    }
                }

            }
        }

        private void OnInspectorUpdate()
        {
            OnSelectionChange();
        }
        #endregion

        #region TempPainter Method
        void PaintVertexColor()
        {
            if (m_target&&m_active)
            {
                curMesh = SVTXPainterUtils.GetMesh(m_active);
                if (curMesh)
                {
                    if (isRecord)
                    {
                        m_target.PushUndo();
                        isRecord = false;
                    }
                    Vector3[] verts = curMesh.vertices;
                    Color[] colors = new Color[0];
                    if (curMesh.colors.Length > 0)
                    {
                        colors = curMesh.colors;
                    }
                    else
                    {
                        colors = new Color[verts.Length];
                    }
                    for (int i = 0; i < verts.Length; i++)
                    {
                        Vector3 vertPos = m_target.transform.TransformPoint(verts[i]);
                        float mag = (vertPos - curHit.point).magnitude;
                        if (mag > (pickColor ? pickColorSize : brushSize))
                        {
                            continue;
                        }
                        if (pickColor)
                        {
                            brushColor = curMesh.colors[i];
                            switch (curColorChannel) {
                                case 1:
                                    brushIntensity = brushColor.r;
                                    break;
                                case 2:
                                    brushIntensity = brushColor.g;
                                    break;
                                case 3:
                                    brushIntensity = brushColor.b;
                                    break;
                                case 4:
                                    brushIntensity = brushColor.a;
                                    break;
                            }
                             
                            break;
                        }
                        float falloff = SVTXPainterUtils.LinearFalloff(mag, brushSize);
                        falloff = Mathf.Pow(falloff, Mathf.Clamp01(1 - brushFalloff / brushSize)) * brushOpacity;
                        if (curColorChannel == (int)PaintType.All)
                        {
                            colors[i] = SVTXPainterUtils.VTXColorLerp(colors[i], brushColor, falloff, protectOutlineWidth);
                        }
                        else
                        {
                            colors[i] = SVTXPainterUtils.VTXOneChannelLerp(colors[i], brushIntensity, falloff, (PaintType)curColorChannel);
                        }
                        dataChanged = true;
                    }
                    curMesh.colors = colors;
                }
                else
                {
                    OnSelectionChange();
                    Debug.LogWarning("Nothing to paint!");
                }
               
            }
            else
            {
                OnSelectionChange();
                Debug.LogWarning("Nothing to paint!");
            }
        }

        void FillVertexColor()
        {
            if (curMesh)
            {
                Vector3[] verts = curMesh.vertices;
                Color[] colors = new Color[0];
                if (curMesh.colors.Length > 0)
                {
                    
                    colors = curMesh.colors;
                  
                }
                else
                {
                    colors = new Color[verts.Length];
                }
                for (int i = 0; i < verts.Length; i++)
                {
                    if (curColorChannel == (int)PaintType.All)
                    {
                        float p = colors[i].a;
                        colors[i] = brushColor;
                        if (protectOutlineWidth)
                        {
                            colors[i].a = p;
                        }
                       
                    }
                    else
                    {
                        colors[i] = SVTXPainterUtils.VTXOneChannelLerp(colors[i], brushIntensity, 1, (PaintType)curColorChannel);
                    }
                    //Debug.Log("Blend");
                }
                curMesh.colors = colors;
            }
            else
            {
                Debug.LogWarning("Nothing to fill!");
            }
        }
        #endregion

        #region Utility Methods
        void ProcessInputs()
        {
            if (m_target == null)
            {
                return;
            }
            Event e = Event.current;
            mousePos = e.mousePosition;
            if (e.type == EventType.KeyDown)
            {
                if (e.isKey)
                {
                    if (e.keyCode == KeyCode.Z)
                    {
                        allowPainting = !allowPainting;
                        if (allowPainting)
                        {
                            Tools.current = Tool.None;
                        }
                    }
                }
            }
            if (e.type == EventType.MouseUp)
            {
                changingBrushValue = false;
                isPainting = false;

            }
            if (lastMousePos == mousePos)
            {
                isPainting = false;
            }
            if (allowPainting)
            {
                if (e.type == EventType.MouseDrag && e.control && e.button == 0 && !e.shift)
                {
                    brushSize += e.delta.x * 0.005f;
                    brushSize = Mathf.Clamp(brushSize, MinBrushSize, MaxBrushSize);
                    brushFalloff = Mathf.Clamp(brushFalloff, MinBrushSize, brushSize);
                    changingBrushValue = true;
                }
                if (e.type == EventType.MouseDrag && !e.control && e.button == 0 && e.shift)
                {
                    brushOpacity += e.delta.x * 0.005f;
                    brushOpacity = Mathf.Clamp01(brushOpacity);
                    changingBrushValue = true;
                }
                if (e.type == EventType.MouseDrag && e.control && e.button == 0 && e.shift)
                {
                    brushFalloff += e.delta.x * 0.005f;
                    brushFalloff = Mathf.Clamp(brushFalloff, MinBrushSize, brushSize);
                    changingBrushValue = true;
                }
                if ((e.type == EventType.MouseDrag || e.type == EventType.MouseDown) && !e.control && e.button == 0 && !e.shift && !e.alt)
                {
                    isPainting = true;
                    if (e.type == EventType.MouseDown)
                    {
                        isRecord = true;
                    }
                }
            }
            lastMousePos = mousePos;
        }
        void GenerateStyles()
        {
            titleStyle = new GUIStyle();
            titleStyle.border = new RectOffset(3, 3, 3, 3);
            titleStyle.margin = new RectOffset(2, 2, 2, 2);
            titleStyle.fontSize = 25;
            titleStyle.fontStyle = FontStyle.Bold;
            titleStyle.alignment = TextAnchor.MiddleCenter;
        }

        Color getSolidDiscColor(PaintType pt)
        {
            switch (pt)
            {
                case PaintType.All:
                    return new Color(brushColor.r, brushColor.g, brushColor.b, brushOpacity);
                case PaintType.R:
                    return new Color(brushIntensity, 0, 0, brushOpacity);
                case PaintType.G:
                    return new Color(0, brushIntensity, 0, brushOpacity);
                case PaintType.B:
                    return new Color(0, 0, brushIntensity, brushOpacity);
                case PaintType.A:
                    return new Color(brushIntensity, 0, brushIntensity, brushOpacity);

            }
            return Color.white;
        }
        Color getWireDiscColor(PaintType pt)
        {
            switch (pt)
            {
                case PaintType.All:
                    return new Color(1 - brushColor.r, 1 - brushColor.g, 1 - brushColor.b, 1);
                case PaintType.R:
                    return Color.white;
                case PaintType.G:
                    return Color.white;
                case PaintType.B:
                    return Color.white;
                case PaintType.A:
                    return Color.white;
            }
            return Color.white;
        }
        #endregion

    }

}