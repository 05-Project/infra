## ArgoCD 설치 및 설정

- ArgoCD 설치
    
    ```bash
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    ```
    
- ArgoCD 접근 설정
    
    ```bash
    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
    kubectl get svc argocd-server -n argocd
    ```
    
- 서비스 주소로 접속
  
  ![images](https://github.com/user-attachments/assets/555bfebd-3770-4289-ba25-90a6101a6770)


- 로그인
    - 아이디 :  admin
    - 비밀번호 알아내기
        
        ```bash
        kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
        ```
        

## ArgoCD GitOAuth로 접속하는 방법

### OAuth앱 생성

- 앱 생성
    - organization의 settings → Developer settings → OAuth Apps 선택
    
    ![image](https://github.com/user-attachments/assets/1d7a97be-7c4d-4927-ae53-785d6a24c92e)
    
   ![화면 캡처 2024-11-21 185858](https://github.com/user-attachments/assets/9643cc97-28e8-43a0-a3ed-f2672f615530)
    
    - Application Name : OAuth의 이름을 지정
    - Homepage URL : ArgoCD의 홈페이지 주소
    - Authorization callback URL : ArgoCD 홈페이지 주소/api/dex/callback 형식
- OAuths Client ID와 Client secrets
    
    ![화면 캡처 2024-11-21 190103](https://github.com/user-attachments/assets/0625b7a7-1008-4b3f-a9f9-e14d1ed0d6bd)
    
    - Client ID와 Client secrets는 argoCD의 컨피그맵에 사용됨
    - Client secrets는 Generate a new client secret를 눌러서 생성함
        - 단, 버튼 누른 그 때만 확인이 가능하고 그 다음에는 확인할 수 없음

### 컨피그맵 수정

```bash
kubectl edit cm argocd-cm -n argocd
```

![화면 캡처 2024-11-21 192915](https://github.com/user-attachments/assets/fd86d28c-01a7-4975-8769-484186ab3f62)
### RBAC 수정

```bash
kubectl edit cm argocd-rbac-cm -n argocd
```

![화면 캡처 2024-11-21 193034](https://github.com/user-attachments/assets/1e4d9b16-d515-4b41-9119-d14e64d70e20)

### 접속 화면

![화면 캡처 2024-11-21 193321](https://github.com/user-attachments/assets/0a6c39e7-7094-4a2b-96b3-e7bd98b1a1a1)

GitHub 로그인 버튼이 추가되었음

- GitHub 계정 로그인하면 접속이 됨
    
    ![화면 캡처 2024-11-21 203616](https://github.com/user-attachments/assets/6efd8d06-b945-4da0-9389-cc06e549cfea)
  
## ArgoCD Repo 연결하기 (GitHub 방식)

### GitHub Apps 생성

- organization의 settings → Developer settings → GitHub Apps 선택
- New GitHub App 선택하여 생성
    
    ![화면 캡처 2024-11-21 204331](https://github.com/user-attachments/assets/cd89cb22-6f96-4fbd-a3ea-cae21e423368)
    
    ![화면 캡처 2024-11-21 204412](https://github.com/user-attachments/assets/a335f0e4-23e9-4e04-9e49-15d8dd51ae99)
    
    - GitHub App name : GitHub App 이름
    - Homepage URL : 연결한 repository의 URL
    
    ![화면 캡처 2024-11-21 204736](https://github.com/user-attachments/assets/d79a6f97-a86a-43ab-9fb6-a2603912bf92)
    
    - Webhook 해제
    
    ![화면 캡처 2024-11-21 204706](https://github.com/user-attachments/assets/baf89150-687e-4e7e-951d-47db73bd6c29)
    
    - Repository Permissions 선택:
        - Contents: Read-only
        - Metadata: Read-only
    - Organization Permissions 선택:
        - Self-hosted runners: Read-only
    - Only on this account 선택
- 생성 후 화면
    
    ![화면 캡처 2024-11-21 205352](https://github.com/user-attachments/assets/e3082899-a593-4412-8610-e6e5735aee8b)
    
    - App ID, Client ID : Repository 연결 할 때 사용할 값
    - Generate a new client secret를 눌러서 Client secrets를 만들기
        - 단, 버튼 누른 그 때만 확인이 가능하고 그 다음에는 확인할 수 없음
    - Generate a private key를 눌러서 private key 다운로드
        
       ![화면 캡처 2024-11-21 205731](https://github.com/user-attachments/assets/ef6c09bc-3601-405b-b19b-575e6ba64bdc))
        
- App을 Repo에 설치
    - Install App → Install 클릭
    
    ![화면 캡처 2024-11-21 205833](https://github.com/user-attachments/assets/bcf56ed9-5924-4804-94f6-d96738c8b722)
    
    ![화면 캡처 2024-11-21 205931](https://github.com/user-attachments/assets/55ea046a-9fcf-4c3c-935f-7d90641c070a))
    
    ![화면 캡처 2024-11-21 210004](https://github.com/user-attachments/assets/372d34b7-08bd-43c9-813e-cfc868d84d9c)
    
    - 생성 후 도메인에서 맨 끝 숫자부분이 Installation ID임

### Repo 연결

- Settings → Repositories → CONNECT REPO 선택

![화면 캡처 2024-11-21 203745](https://github.com/user-attachments/assets/7d3b1723-b6a3-46f6-9dae-3d001add67da)

![화면 캡처 2024-11-21 203848](https://github.com/user-attachments/assets/9c48d57f-6a2e-4b31-8f0d-73d6afd6929e)
    
![화면 캡처 2024-11-21 203932](https://github.com/user-attachments/assets/b35ceabe-620b-4964-ac78-1ad6ba51a502)
    
![화면 캡처 2024-11-21 210612](https://github.com/user-attachments/assets/7e81ee08-cfe2-4930-bb30-6d0409bbba82)
