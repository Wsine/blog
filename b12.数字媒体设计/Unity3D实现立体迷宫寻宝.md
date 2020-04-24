# Unity3D实现立体迷宫寻宝

这个小游戏是一个白痴在一个昏暗的房间走动找到关键得分点，然后通关游戏。入门Unity3D做的第一款游戏，比较无聊，但实现了一般的游戏功能。如，人物控制，碰撞检测，主控制器等。

### 游戏界面

![123](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image232.png)
![456](https://wsine.cn-gd.ufileos.com/image/wsine-blog-image233.png)

### 控制代码

GameManager.cs
主控制脚本：用于控制整个游戏的主逻辑，屏幕显示一些提示字符以及游戏分数，并且根据游戏逻辑更新数值。同时，检测按键是否需要退出。

```
using UnityEngine;
using System.Collections;

[AddComponentMenu("Game/GameManager")]
public class GameManager : MonoBehaviour {
    public static GameManager Instance = null;

    // 游戏得分
    public int m_score = 0;
    // 游戏主角
    Player m_player;

    // UI文字
    GUIText txt_hiscore;
    GUIText txt_score;
	GUIText txt_win;

	// 初始化
	void Start () {
        Instance = this;
        // 获得主角
        m_player = GameObject.FindGameObjectWithTag("Player").GetComponent<Player>();

        // 获得设置的UI文字
        txt_score = this.transform.FindChild("txt_score").GetComponent<GUIText>();
		txt_win = this.transform.FindChild("txt_win").GetComponent<GUIText>();
	}
	// 游戏胜利
	public void setWin(){
		txt_win.gameObject.SetActive (true);
		m_player.enabled = false;
	}
	// 退出游戏
    void Update(){
        if (Input.GetKeyDown(KeyCode.Escape))
            Application.Quit();
    }
    // 更新分数
    public void SetScore(int score){
        m_score+= score;
        txt_score.text = "Score "+m_score;
    }
}
```

ItemHit.cs
碰撞检测脚本：碰撞得分+1，如果是最后一个得分点，则标识游戏胜利。

```
using UnityEngine;
using System.Collections;

public class ItemHit : MonoBehaviour {
	// Use this for initialization
	void Start () {
	
	}

	void OnTriggerEnter(Collider other) {
		//判断palyer对象是否和得分点接触
		if( other.tag == "Player" ){
			GameObject.Destroy( this.gameObject );
			GameManager.Instance.SetScore(1);
			//判断全部得分点都已经过，结束游戏，打印win
			if( GameObject.FindObjectsOfType<ItemHit>().Length == 1 ){
				GameManager.Instance.setWin();
			}
		}
	}
}
```

player.cs
人物控制脚本：在这里可以控制对象的一些属性，例如重力数值，移动速度，摄像机参数，初始生命值。
Start( )的时候需要绑定对象；
Update( )的时候需要更新人物位置，并且让小摄像机追踪人物，小摄像机用于小地图显示人物当前位置。

```
using UnityEngine;
using System.Collections;

[AddComponentMenu("Game/Player")]
public class Player : MonoBehaviour {

    // 组件
    public Transform m_transform;
    CharacterController m_ch;
	
    // 角色移动速度
    float m_movSpeed = 10.0f;

    // 重力
    float m_gravity = 2.0f;
	
    // 摄像机
    Transform m_camTransform;

    // 摄像机旋转角度
    Vector3 m_camRot;

    // 摄像机高度
    float m_camHeight = 1.4f;

    // 生命值
    public int m_life = 5;

	void Start () {

        // 获取组件
        m_transform = this.transform;
        m_ch = this.GetComponent<CharacterController>();

        // 获取摄像机
        m_camTransform = Camera.main.transform;

        // 设置摄像机初始位置
        Vector3 pos = m_transform.position;
        pos.y += m_camHeight;
        m_camTransform.position = pos;
        m_camTransform.rotation = m_transform.rotation;

        m_camRot = m_camTransform.eulerAngles;

        Screen.lockCursor = true;

	}

	void Update () {
        Control();
	}

    void Control(){    
        //获取鼠标移动距离
        float rh = Input.GetAxis("Mouse X");
        float rv = Input.GetAxis("Mouse Y");

        // 旋转摄像机
        m_camRot.x -= rv;
        m_camRot.y += rh;
        m_camTransform.eulerAngles = m_camRot;

        // 使主角的面向方向与摄像机一致
        Vector3 camrot = m_camTransform.eulerAngles;
        camrot.x = 0; camrot.z = 0;
        m_transform.eulerAngles = camrot;
		     
        float xm = 0, ym = 0, zm = 0;

        // 重力运动
        ym -= m_gravity*Time.deltaTime;

        // 上下左右运动
        if (Input.GetKey(KeyCode.W)){
            zm += m_movSpeed * Time.deltaTime;
        }
        else if (Input.GetKey(KeyCode.S)){
            zm -= m_movSpeed * Time.deltaTime;
        }

        if (Input.GetKey(KeyCode.A)){
            xm -= m_movSpeed * Time.deltaTime;
        }
        else if (Input.GetKey(KeyCode.D)){
            xm += m_movSpeed * Time.deltaTime;
        }
        //移动
        m_ch.Move( m_transform.TransformDirection(new Vector3(xm, ym, zm)) );

        // 使摄像机的位置与主角一致
        Vector3 pos = m_transform.position;
        pos.y += m_camHeight;
        m_camTransform.position = pos;			      
    }
}

```

### 完整工程

传送门：[这里](http://pan.baidu.com/s/1hq6djIs)